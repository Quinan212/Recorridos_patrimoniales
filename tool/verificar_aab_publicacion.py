"""Verifica el AAB de publicación contra la clave y el PEM del proyecto."""

import hashlib
import json
import os
from pathlib import Path
import re
import shutil
import ssl
import struct
import subprocess
import xml.etree.ElementTree as ET
import zipfile


PROJECT = Path(__file__).resolve().parents[1]
SIGNING = PROJECT / "android" / "firma-upload"
BUNDLE = PROJECT / "build/app/outputs/bundle/release/app-release.aab"
TOOLS = Path("C:/Users/alan/Desktop/Recorridos Patrimoniales/pruebas-mapas/integracion-app/firma-play-4395")
JDK = Path(os.environ.get("JAVA_HOME", "C:/Program Files/Android/Android Studio/jbr")) / "bin"


def run(args, name):
    result = subprocess.run([str(a) for a in args], capture_output=True)
    (SIGNING / name).write_bytes(result.stdout + result.stderr)
    if result.returncode:
        raise RuntimeError(f"Falló la validación; revisar {name}.")
    return result.stdout.decode("utf-8", errors="replace")


def main():
    version = re.search(r"(?m)^version:\s*([^+\s]+)\+(\d+)",
                        (PROJECT / "pubspec.yaml").read_text(encoding="utf-8"))
    assert version and version.group(2) == "387"
    tool = TOOLS / "bundletool-all-1.18.3.jar"
    assert BUNDLE.is_file() and tool.is_file()
    run([JDK / "java.exe", "-jar", tool, "validate", f"--bundle={BUNDLE}"],
        "validacion-bundletool-387.log")
    manifest = run([JDK / "java.exe", "-jar", tool, "dump", "manifest", f"--bundle={BUNDLE}"],
                   "manifest-387.xml")
    root = ET.fromstring(manifest)
    ns = "{http://schemas.android.com/apk/res/android}"
    assert root.get("package") == "ar.maillet.recorridos_patrimoniales"
    assert root.get(ns + "versionCode") == version.group(2)
    assert root.get(ns + "versionName") == version.group(1)
    assert root.find("application").get(ns + "debuggable") != "true"
    signature = run([JDK / "jarsigner.exe", "-J-Duser.language=en", "-verify", BUNDLE],
                    "verificacion-firma-387.log")
    assert "jar verified." in signature
    certificate = run([JDK / "keytool.exe", "-J-Duser.language=en", "-printcert", "-rfc",
                       "-jarfile", BUNDLE], "certificado-aab-387.pem")
    match = re.search(r"-----BEGIN CERTIFICATE-----.*?-----END CERTIFICATE-----", certificate, re.S)
    assert match
    fingerprint = hashlib.sha256(ssl.PEM_cert_to_DER_cert(match[0])).hexdigest()
    expected = hashlib.sha256(ssl.PEM_cert_to_DER_cert(
        (SIGNING / "upload-certificate.pem").read_text(encoding="ascii"))).hexdigest()
    assert fingerprint == expected, "El AAB debe usar exactamente el certificado enviado a Play."
    alignments = []
    with zipfile.ZipFile(BUNDLE) as z:
        names = z.namelist()
        assert not any(n.endswith("kernel_blob.bin") for n in names)
        for abi in ["armeabi-v7a", "arm64-v8a", "x86_64"]:
            for library in ["libapp.so", "libmaplibre.so"]:
                assert f"base/lib/{abi}/{library}" in names
        for name in names:
            if not name.startswith("base/lib/") or not name.endswith(".so"):
                continue
            data = z.read(name)
            assert data[:4] == b"\x7fELF"
            if data[4] != 2:
                continue
            endian = "<" if data[5] == 1 else ">"
            offset = struct.unpack_from(endian + "Q", data, 32)[0]
            size, count = struct.unpack_from(endian + "HH", data, 54)
            for i in range(count):
                segment = struct.unpack_from(endian + "IIQQQQQQ", data, offset + i * size)
                if segment[0] == 1:
                    assert segment[7] >= 16384, name
                    assert (segment[2] - segment[3]) % 16384 == 0, name
            alignments.append(name)
        assert not any("firma-upload/" in n or n.endswith("key.properties") or
                       n.endswith(".jks") for n in names)
        tile_count = sum(n.startswith("base/assets/flutter_assets/assets/mapa_3d/") and
                         n.endswith(".pbf") for n in names)
        assert tile_count > 0
    destination = Path.home() / "Downloads" / f"Recorridos-Patrimoniales-{version.group(1)}-387-release.aab"
    if destination.exists() and destination.read_bytes() != BUNDLE.read_bytes():
        raise RuntimeError("Ya existe un AAB distinto con ese nombre; se conserva.")
    shutil.copy2(BUNDLE, destination)
    result = {"aab": str(destination), "projectBundle": str(BUNDLE),
              "package": root.get("package"), "versionName": version.group(1),
              "versionCode": 387, "targetSdk": root.find("uses-sdk").get(ns + "targetSdkVersion"),
              "certificateSha256": fingerprint, "certificateMatchesUploadedPEM": True,
              "bundletoolValid": True, "aot": True, "offlineTiles": tile_count,
              "native16KAligned": alignments, "privateSigningFilesExcluded": True,
              "bytes": destination.stat().st_size,
              "sha256": hashlib.sha256(destination.read_bytes()).hexdigest(),
              "playUploadKeyStatus": "solicitud enviada; pendiente en Play Console"}
    (SIGNING / "verificacion-aab-387.json").write_text(
        json.dumps(result, ensure_ascii=False, indent=2), encoding="utf-8")
    print(json.dumps(result, ensure_ascii=False, indent=2))


if __name__ == "__main__":
    main()
