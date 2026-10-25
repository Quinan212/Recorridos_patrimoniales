"""Guarda y verifica un respaldo privado de la firma fuera del proyecto."""

from datetime import datetime, timedelta, timezone
import hashlib
import json
import os
from pathlib import Path
import shutil
import ssl
import subprocess

from preparar_firma_upload import PROJECT, SIGNING, protect


def main():
    date = datetime.now(timezone(timedelta(hours=-3))).strftime("%Y-%m-%d")
    destination = Path.home() / "Documents" / "Recorridos-Patrimoniales-Respaldo-Firma" / date
    assert not destination.resolve().is_relative_to(PROJECT.resolve())
    destination.parent.mkdir(parents=True, exist_ok=True)
    protect(destination.parent, directory=True)
    destination.mkdir(exist_ok=True)
    protect(destination, directory=True)
    files = ["upload-keystore.jks", "credenciales.properties", "upload-certificate.pem",
             "certificado-publico.json", "verificacion-aab-387.json", "solicitud-google-play.json"]
    hashes = {}
    for name in files:
        source, backup = SIGNING / name, destination / name
        if not source.is_file():
            raise RuntimeError(f"Falta el archivo de origen: {name}.")
        if backup.exists() and backup.read_bytes() != source.read_bytes():
            raise RuntimeError(f"Ya existe un respaldo distinto: {name}; no se sobrescribe.")
        if not backup.exists():
            shutil.copy2(source, backup)
        protect(backup)
        expected = hashlib.sha256(source.read_bytes()).hexdigest()
        actual = hashlib.sha256(backup.read_bytes()).hexdigest()
        assert expected == actual, name
        hashes[name] = actual

    config = destination / "key.properties"
    source_config = PROJECT / "android/key.properties"
    assert source_config.read_bytes() == (SIGNING / "credenciales.properties").read_bytes()
    if config.exists() and config.read_bytes() != source_config.read_bytes():
        raise RuntimeError("La configuración del respaldo es distinta; se conserva.")
    shutil.copy2(source_config, config)
    protect(config)
    hashes[config.name] = hashlib.sha256(config.read_bytes()).hexdigest()

    settings = dict(line.split("=", 1) for line in
                    (destination / "credenciales.properties").read_text(encoding="utf-8").splitlines()
                    if "=" in line)
    environment = os.environ.copy()
    environment["RECORRIDOS_BACKUP_STOREPASS"] = settings["storePassword"]
    environment["RECORRIDOS_BACKUP_KEYPASS"] = settings["keyPassword"]
    candidates = [Path(os.environ.get("JAVA_HOME", "")) / "bin/keytool.exe",
                  Path("C:/Program Files/Android/Android Studio/jbr/bin/keytool.exe")]
    keytool = next((p for p in candidates if p.is_file()), None)
    if keytool is None:
        raise RuntimeError("No se encontró keytool para verificar la copia.")

    def run(args):
        result = subprocess.run([str(keytool), "-J-Duser.language=en", *args,
                                 "-keystore", str(destination / "upload-keystore.jks"),
                                 "-alias", settings["keyAlias"], "-storepass:env",
                                 "RECORRIDOS_BACKUP_STOREPASS"],
                                env=environment, capture_output=True)
        if result.returncode:
            raise RuntimeError("Falló la verificación del keystore de respaldo.")
        return result.stdout

    listing = run(["-list", "-v"])
    assert b"PrivateKeyEntry" in listing
    # Crear una petición en memoria exige descifrar y usar la clave privada de la copia.
    request = run(["-certreq", "-keypass:env", "RECORRIDOS_BACKUP_KEYPASS"])
    assert b"CERTIFICATE REQUEST" in request
    certificate = run(["-exportcert", "-rfc"]).decode("ascii")
    fingerprint = hashlib.sha256(ssl.PEM_cert_to_DER_cert(certificate)).hexdigest()
    expected_certificate = hashlib.sha256(ssl.PEM_cert_to_DER_cert(
        (destination / "upload-certificate.pem").read_text(encoding="ascii"))).hexdigest()
    assert fingerprint == expected_certificate
    aab = json.loads((destination / "verificacion-aab-387.json").read_text(encoding="utf-8"))
    assert aab["certificateSha256"] == fingerprint

    report = {"backup": str(destination), "original": str(SIGNING),
              "checkedAt": datetime.now(timezone(timedelta(hours=-3))).isoformat(),
              "sha256": hashes, "allCopiesIdentical": True,
              "privateKeyUsable": True, "certificateMatchesPEMAndAAB387": True,
              "certificateSha256": fingerprint,
              "location": "fuera del proyecto, en el mismo equipo"}
    manifest = destination / "verificacion-respaldo.json"
    manifest.write_text(json.dumps(report, ensure_ascii=False, indent=2), encoding="utf-8")
    protect(manifest)
    instructions = destination / "LEEME-RESTAURAR.txt"
    instructions.write_text(
        "RESPALDO PRIVADO DE FIRMA - RECORRIDOS PATRIMONIALES\n\n"
        "Incluye la clave privada original, sus contraseñas, el PEM público y comprobantes.\n"
        "La copia se verificó por SHA-256 y usando realmente la clave privada.\n\n"
        "Para restaurar: cerrar compilaciones; copiar upload-keystore.jks, credenciales.properties\n"
        "y upload-certificate.pem a android/firma-upload/ dentro del proyecto. Copiar key.properties\n"
        "a android/key.properties. No reemplazar otros archivos de firma sin verificar su identidad.\n"
        "La ruta relativa supone android/firma-upload/upload-keystore.jks.\n\n"
        "El PEM es público; el .jks y las credenciales deben mantenerse privados.\n"
        "Este respaldo está fuera del proyecto pero en el mismo equipo.\n",
        encoding="utf-8")
    protect(instructions)
    print(json.dumps({k: v for k, v in report.items() if k != "sha256"},
                     ensure_ascii=False, indent=2))


if __name__ == "__main__":
    main()
