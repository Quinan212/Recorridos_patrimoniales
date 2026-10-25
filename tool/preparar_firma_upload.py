"""Prepara o verifica la clave local de subida sin mostrar sus contraseñas."""

from datetime import datetime, timedelta, timezone
import hashlib
import json
import os
from pathlib import Path
import secrets
import shutil
import ssl
import subprocess


PROJECT = Path(__file__).resolve().parents[1]
SIGNING = PROJECT / "android" / "firma-upload"
KEYSTORE = SIGNING / "upload-keystore.jks"
CREDENTIALS = SIGNING / "credenciales.properties"
CERTIFICATE = SIGNING / "upload-certificate.pem"
GRADLE_PROPERTIES = PROJECT / "android" / "key.properties"


def protect(path, directory=False):
    if os.name == "nt":
        identity = subprocess.check_output(
            ["whoami", "/user", "/fo", "csv", "/nh"], text=True
        ).strip().split(",")[-1].strip('"')
        access = "(OI)(CI)F" if directory else "F"
        subprocess.run(
            ["icacls", str(path), "/inheritance:r", "/grant:r",
             f"*{identity}:{access}", f"*S-1-5-18:{access}"],
            check=True, capture_output=True,
        )
    else:
        path.chmod(0o700 if directory else 0o600)


def run_keytool(keytool, args, password):
    environment = os.environ.copy()
    environment["RECORRIDOS_SIGNING_PASSWORD"] = password
    result = subprocess.run(
        [str(keytool), "-J-Duser.language=en", *args,
         "-storepass:env", "RECORRIDOS_SIGNING_PASSWORD"],
        env=environment, capture_output=True,
    )
    if result.returncode:
        raise RuntimeError("keytool no pudo completar la operación de firma.")
    return result.stdout


def main():
    candidates = [Path(os.environ.get("JAVA_HOME", "")) / "bin" / "keytool.exe",
                  Path("C:/Program Files/Android/Android Studio/jbr/bin/keytool.exe")]
    found = shutil.which("keytool")
    if found:
        candidates.append(Path(found))
    keytool = next((p for p in candidates if p.is_file()), None)
    if keytool is None:
        raise RuntimeError("No se encontró keytool del JDK.")

    SIGNING.mkdir(parents=True, exist_ok=True)
    protect(SIGNING, directory=True)
    created = not KEYSTORE.exists()
    if created:
        if CREDENTIALS.exists():
            raise RuntimeError("Hay credenciales sin keystore: revisar antes de generar otra clave.")
        password = secrets.token_urlsafe(48)
        properties = {"storePassword": password, "keyPassword": password,
                      "keyAlias": "upload", "storeFile": "../firma-upload/upload-keystore.jks"}
        CREDENTIALS.write_text(
            "".join(f"{k}={v}\n" for k, v in properties.items()), encoding="utf-8"
        )
        protect(CREDENTIALS)
        environment = os.environ.copy()
        environment["RECORRIDOS_SIGNING_PASSWORD"] = password
        result = subprocess.run(
            [str(keytool), "-genkeypair", "-storetype", "JKS", "-keystore", str(KEYSTORE),
             "-alias", "upload", "-keyalg", "RSA", "-keysize", "4096", "-validity", "10000",
             "-sigalg", "SHA256withRSA", "-dname",
             "CN=Recorridos Patrimoniales, O=Recorridos Patrimoniales, L=Concordia, ST=Entre Rios, C=AR",
             "-storepass:env", "RECORRIDOS_SIGNING_PASSWORD",
             "-keypass:env", "RECORRIDOS_SIGNING_PASSWORD", "-noprompt"],
            env=environment, capture_output=True,
        )
        if result.returncode:
            raise RuntimeError("No se pudo generar el keystore; se conserva el estado para revisión.")
        protect(KEYSTORE)
    else:
        if not CREDENTIALS.exists():
            raise RuntimeError("Existe el keystore y faltan sus credenciales; no se reemplaza.")
        properties = dict(line.split("=", 1) for line in CREDENTIALS.read_text(
            encoding="utf-8").splitlines() if "=" in line)
        password = properties["storePassword"]

    listing = run_keytool(keytool, ["-list", "-v", "-keystore", str(KEYSTORE),
                                  "-alias", properties["keyAlias"]], password)
    if b"PrivateKeyEntry" not in listing:
        raise RuntimeError("El almacén no contiene la entrada de clave privada esperada.")
    exported = run_keytool(keytool, ["-exportcert", "-rfc", "-keystore", str(KEYSTORE),
                                   "-alias", properties["keyAlias"]], password)
    if CERTIFICATE.exists() and CERTIFICATE.read_bytes() != exported:
        raise RuntimeError("El certificado guardado no coincide: no se reemplaza.")
    CERTIFICATE.write_bytes(exported)
    protect(CERTIFICATE)
    certificate_hash = hashlib.sha256(ssl.PEM_cert_to_DER_cert(
        exported.decode("ascii"))).hexdigest()

    new_config = CREDENTIALS.read_text(encoding="utf-8")
    if GRADLE_PROPERTIES.exists() and GRADLE_PROPERTIES.read_text(encoding="utf-8") != new_config:
        stamp = datetime.now(timezone(timedelta(hours=-3))).strftime("%Y%m%d-%H%M%S")
        backup = SIGNING / f"key.properties-anterior-{stamp}"
        shutil.copy2(GRADLE_PROPERTIES, backup)
        protect(backup)
    GRADLE_PROPERTIES.write_text(new_config, encoding="utf-8")
    protect(GRADLE_PROPERTIES)

    metadata = {"createdAt": datetime.now(timezone(timedelta(hours=-3))).isoformat(),
                "keyAlias": properties["keyAlias"], "keystore": str(KEYSTORE),
                "certificate": str(CERTIFICATE), "certificateSha256": certificate_hash,
                "algorithm": "RSA", "bits": 4096}
    if created or not (SIGNING / "certificado-publico.json").exists():
        (SIGNING / "certificado-publico.json").write_text(
            json.dumps(metadata, ensure_ascii=False, indent=2), encoding="utf-8")
    (SIGNING / "LEEME.txt").write_text(
        "Firma de subida de Recorridos Patrimoniales\n\n"
        "upload-keystore.jks: clave privada para firmar próximas actualizaciones.\n"
        "credenciales.properties: contraseñas y alias. Mantener ambos archivos privados.\n"
        "upload-certificate.pem: certificado público para restablecer la clave de subida en Google Play.\n"
        "android/key.properties usa una ruta relativa al proyecto; se puede mover la carpeta completa.\n"
        "Conservar un respaldo privado de esta carpeta. Está excluida de Git.\n"
        "El PEM público no reemplaza el keystore privado.\n", encoding="utf-8")
    print(json.dumps({**metadata, "createdNewKey": created}, ensure_ascii=False, indent=2))


if __name__ == "__main__":
    main()
