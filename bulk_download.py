import os
import requests
import re

# Directorio de destino
desktop = os.path.join(os.path.expanduser("~"), "Desktop")
output_dir = os.path.join(desktop, "Descargas_Fotos_Patrimonio")

if not os.path.exists(output_dir):
    os.makedirs(output_dir)

# Lista de URLs proporcionada por el usuario
urls = [
    "https://i.pinimg.com/1200x/1e/f2/f3/1ef2f3c276189c32ac25960b4254092d.jpg",
    "https://i.pinimg.com/1200x/60/bd/53/60bd5348be1a83b7c9cf000ced12391a.jpg",
    "https://i.pinimg.com/1200x/6a/97/0f/6a970fc1b6aeedba7f5cef876925a05e.jpg",
    "https://i.pinimg.com/1200x/7a/7d/0e/7a7d0e685b517ce67ade5ffe60c4e28d.jpg",
    "https://i.pinimg.com/1200x/8d/c5/5d/8dc55de6c5845915655ce334205895fc.jpg",
    "https://i.pinimg.com/1200x/8f/e6/45/8fe64521b3f1e6feb1f65f558b253cfc.jpg",
    "https://i.pinimg.com/1200x/c3/00/cc/c300ccf7c74aa2bf3dc1ca79f8747042.jpg",
    "https://i.pinimg.com/1200x/ec/cd/c3/eccdc33bd251d0b21c0f938875331613.jpg",
    "https://i.pinimg.com/736x/01/cb/89/01cb898e4520cbafec5557ef178237a9.jpg",
    "https://i.pinimg.com/736x/02/3f/a1/023fa1117d4c5870e1c41d6020dc5265.jpg",
    "https://i.pinimg.com/736x/02/b0/e9/02b0e9151fc617df3ee5d61cf49656a0.jpg",
    "https://i.pinimg.com/736x/0c/a4/05/0ca40581653741e61756d0818a866ba1.jpg",
    "https://i.pinimg.com/736x/0e/3b/ea/0e3beabbb0694eba2f736ca7bbb0d9b8.jpg",
    "https://i.pinimg.com/736x/12/6b/85/126b858965a4e52c122f435422aded79.jpg",
    "https://i.pinimg.com/736x/17/87/cd/1787cd0c36c1078cd7527341608fb08b.jpg",
    "https://i.pinimg.com/736x/17/da/d4/17dad45425d89690524afdd982f3d2fa.jpg",
    "https://i.pinimg.com/736x/19/09/8f/19098f1671ab425f432f28b763b13e5c.jpg",
    "https://i.pinimg.com/736x/19/9d/87/199d871c8c737234448a9d27896484ec.jpg",
    "https://i.pinimg.com/736x/19/e4/ec/19e4ec833085237521d39f4062e65337.jpg",
    "https://i.pinimg.com/736x/1b/51/21/1b5121a9ad70ed39c1880d1c8071c07b.jpg",
    "https://i.pinimg.com/736x/25/6b/b6/256bb66ee2fc07d4f0006c4628983212.jpg",
    "https://i.pinimg.com/736x/2a/3d/13/2a3d133016064c763eae5582896cc425.jpg",
    "https://i.pinimg.com/736x/2b/87/d9/2b87d9b46128e0cffbe9bf599ac8b3f9.jpg",
    "https://i.pinimg.com/736x/2c/49/fd/2c49fd6d59bd366565a180e0c45e4b6b.jpg",
    "https://i.pinimg.com/736x/2d/0f/df/2d0fdf535511d04907815ef2edf8b794.jpg",
    "https://i.pinimg.com/736x/31/18/0a/31180aae4a45d7dae6136c39aceb0034.jpg",
    "https://i.pinimg.com/736x/32/53/9a/32539aca98ec2ebf1f3e76c52a0281bb.jpg",
    "https://i.pinimg.com/736x/36/c0/96/36c096ca644de386a31c0e5b0d8893c1.jpg",
    "https://i.pinimg.com/736x/38/21/4c/38214c814ab4bd356bac9c316b8dcc69.jpg",
    "https://i.pinimg.com/736x/39/c3/08/39c308720d2606785e54bab484a8ea08.jpg",
    "https://i.pinimg.com/736x/3a/1a/00/3a1a008197f920eecf28b5580bbb12b0.jpg",
    "https://i.pinimg.com/736x/3a/d4/ee/3ad4ee508817855bf95922ad1b9acfb7.jpg",
    "https://i.pinimg.com/736x/3b/35/7e/3b357efb42391bf0bc37e98036486324.jpg",
    "https://i.pinimg.com/736x/3b/ac/fe/3bacfeb10212fee0e85b6a3936eab299.jpg",
    "https://i.pinimg.com/736x/3d/7e/fa/3d7efa03c39bfb65df9ce147d784b856.jpg",
    "https://i.pinimg.com/736x/3e/ee/4a/3eee4a776ed1122adca3a9ff565db20a.jpg",
    "https://i.pinimg.com/736x/41/5b/29/415b29554c3717f0b34eddd603428882.jpg",
    "https://i.pinimg.com/736x/46/4e/b7/464eb7d474b6ff687b0ff274cbb6687c.jpg",
    "https://i.pinimg.com/736x/47/de/95/47de959d0836f12b94415529a70185f6.jpg",
    "https://i.pinimg.com/736x/4b/ef/a9/4befa9c38969010944794f983b28962e.jpg",
    "https://i.pinimg.com/736x/4c/35/50/4c355015b6bd9384d9ff2bafd68beffc.jpg",
    "https://i.pinimg.com/736x/4c/4e/12/4c4e124dba30ac8ee141d6213d3c9f66.jpg",
    "https://i.pinimg.com/736x/4e/fa/c0/4efac035e41a223b6421ad2bd15c80e0.jpg",
    "https://i.pinimg.com/736x/50/96/fc/5096fc8ea3e5d6396e7b8090d69daf35.jpg",
    "https://i.pinimg.com/736x/53/3f/d6/533fd601bb2dcaf334809b67d97a1c63.jpg",
    "https://i.pinimg.com/736x/54/64/95/546495e3231ecc3bc2fcdf7582d20f9f.jpg",
    "https://i.pinimg.com/736x/56/8a/04/568a04e8ed5de107964fed43bc955e26.jpg",
    "https://i.pinimg.com/736x/60/0f/92/600f927eb03cc7439501f8c3497c027c.jpg",
    "https://i.pinimg.com/736x/60/d8/e9/60d8e98162ad696257a880a4471e6085.jpg",
    "https://i.pinimg.com/736x/60/ec/76/60ec760a685bd60a642e9a93e2d3cf3f.jpg",
    "https://i.pinimg.com/736x/64/e4/5e/64e45e5a1e933691f66e02678e2fa630.jpg",
    "https://i.pinimg.com/736x/65/d5/d0/65d5d00c9f9465f79b0c63879bb9d53f.jpg",
    "https://i.pinimg.com/736x/67/26/e7/6726e73097263ac57ff07fc75abc4329.jpg",
    "https://i.pinimg.com/736x/68/1a/8c/681a8c9a9fc4b713a5d223c788cf6792.jpg",
    "https://i.pinimg.com/736x/6e/4a/da/6e4ada997beb11bc418a13e5ea0d8af9.jpg",
    "https://i.pinimg.com/736x/72/b3/7a/72b37aefa0542a951a4a6a85af196c7e.jpg",
    "https://i.pinimg.com/736x/76/02/ea/7602eafab7f95d39d66e0f6057279dca.jpg",
    "https://i.pinimg.com/736x/76/42/44/764244c50df050bacf12b09413fd1701.jpg",
    "https://i.pinimg.com/736x/86/27/22/86272282525f783ce93d233dec796a24.jpg",
    "https://i.pinimg.com/736x/8b/d8/9b/8bd89bc2ca2a7d38e0d347c772d8a91b.jpg",
    "https://i.pinimg.com/736x/90/2d/09/902d092b74ecc2e49482bc82acb5586c.jpg",
    "https://i.pinimg.com/736x/91/82/32/918232e6a4654ab1b8453e96482450bf.jpg",
    "https://i.pinimg.com/736x/92/e0/db/92e0db65bf91800b9ac239d71ee3d33c.jpg",
    "https://i.pinimg.com/736x/95/20/9e/95209e670bce3b7d26f231aa5b6e6fc8.jpg",
    "https://i.pinimg.com/736x/9a/84/cd/9a84cd81105d65fd9f058603bc4289ad.jpg",
    "https://i.pinimg.com/736x/9a/f0/33/9af03300564c792a78336158003b7303.jpg",
    "https://i.pinimg.com/736x/a0/01/a3/a001a319283b531c61ac523dd6d87f22.jpg",
    "https://i.pinimg.com/736x/a1/57/6e/a1576e9017862dae9482116f6f158438.jpg",
    "https://i.pinimg.com/736x/a3/a1/6c/a3a16caa0ac239cf9c95c9de42571abc.jpg",
    "https://i.pinimg.com/736x/a7/c7/95/a7c795f06e6430d343fa4386b151820c.jpg",
    "https://i.pinimg.com/736x/ae/b5/bd/aeb5bd296c654fe31f395d36ccefb7cf.jpg",
    "https://i.pinimg.com/736x/ae/f3/b7/aef3b78b50a61579ed9332ef585b0c7a.jpg",
    "https://i.pinimg.com/736x/af/1b/05/af1b05915ef4967e8d3d5824c2594eb0.jpg",
    "https://i.pinimg.com/736x/af/b1/29/afb12980d26b996db3d049b7bc74923b.jpg",
    "https://i.pinimg.com/736x/b1/bd/a9/b1bda99479e48a908401562284060413.jpg",
    "https://i.pinimg.com/736x/b2/4e/54/b24e54969ffdd795b19f8a141d6f8242.jpg",
    "https://i.pinimg.com/736x/b4/86/bb/b486bbea3f11e45a4ee667fd5619606b.jpg",
    "https://i.pinimg.com/736x/b5/72/d1/b572d144afa7af2ed47472731f13640d.jpg",
    "https://i.pinimg.com/736x/b8/f4/f0/b8f4f0ded08e02eec8b0a8d913f6bc9e.jpg",
    "https://i.pinimg.com/736x/b9/2f/d0/b92fd037d1154ffd7903fd37a180aa28.jpg",
    "https://i.pinimg.com/736x/bb/c7/05/bbc705f5f46008b2beec97bfc82a5ef9.jpg",
    "https://i.pinimg.com/736x/c0/37/b9/c037b97024032138c1b777c8764812b5.jpg",
    "https://i.pinimg.com/736x/c5/6c/b7/c56cb78e38fb59401b3f8fd5e80001b3.jpg",
    "https://i.pinimg.com/736x/c8/7f/1f/c87f1f5fd68e819398da88bf2332c5cd.jpg",
    "https://i.pinimg.com/736x/cd/7e/8b/cd7e8bb1cafe239da4b9b3b6f01291f9.jpg",
    "https://i.pinimg.com/736x/d1/f5/1e/d1f51e5b39a9b98c6f6fd78392e18e0b.jpg",
    "https://i.pinimg.com/736x/d2/9f/75/d29f75a867da876facd7dfa440a4731a.jpg",
    "https://i.pinimg.com/736x/d2/cc/ba/d2ccba8b673e21972fe15c47f08c9d4c.jpg",
    "https://i.pinimg.com/736x/d3/e9/54/d3e95463467cd8ae463a5c07346e238c.jpg",
    "https://i.pinimg.com/736x/d4/09/21/d409212181a7a32cfe77df205d638d77.jpg",
    "https://i.pinimg.com/736x/d7/12/fb/d712fbf0df37e99db49462a0d889c5d5.jpg",
    "https://i.pinimg.com/736x/d8/3e/a2/d83ea23389fe770d10223fb017c10693.jpg",
    "https://i.pinimg.com/736x/d8/b0/ed/d8b0edae6b543c5921918275bfdfe6c8.jpg",
    "https://i.pinimg.com/736x/e3/b3/ef/e3b3efc6036c9053c50391d28f54be85.jpg",
    "https://i.pinimg.com/736x/e4/10/f3/e410f36c50a3fe8a8c2b59d8c660fce4.jpg",
    "https://i.pinimg.com/736x/e4/86/11/e48611f1f96810b7e94df8a08701dd29.jpg",
    "https://i.pinimg.com/736x/e4/c1/1f/e4c11ffc5e7716034de930cf022f6c4f.jpg",
    "https://i.pinimg.com/736x/e5/10/bf/e510bf181fcf9f1f8938ab2e0cde3cf8.jpg",
    "https://i.pinimg.com/736x/e5/93/eb/e593eb423236e6c61e0e8ed24babf6f2.jpg",
    "https://i.pinimg.com/736x/eb/b7/9e/ebb79ed4696daea53a251442fde3939b.jpg",
    "https://i.pinimg.com/736x/ec/81/ba/ec81bae4c010f72a21715c57260ed530.jpg",
    "https://i.pinimg.com/736x/ec/b7/38/ecb738ba3e486f3a0e4798e672ab14c3.jpg",
    "https://i.pinimg.com/736x/ec/c9/be/ecc9bec5e7c1e74ae0e6657944d6275a.jpg",
    "https://i.pinimg.com/736x/fa/8b/7b/fa8b7b273c40b6a98d56a7171f8db684.jpg",
    "https://i.pinimg.com/736x/fe/2a/0f/fe2a0fa372a87f9e8cdf09483b77c76c.jpg",
    "https://i.postimg.cc/0QnkdDnT/Casa-Dr-Cama-o.jpg",
    "https://i.postimg.cc/1zvZnJ4q/181.jpg",
    "https://i.postimg.cc/4NmfVK90/Casa-del-Dr-P-ndola-D-az-3.jpg",
    "https://i.postimg.cc/4Nv0Ykvn/sociedad.png",
    "https://i.postimg.cc/66H68VyR/Casa-del-Dr-P-ndola-D-az-2.jpg",
    "https://i.postimg.cc/8zKBfGpm/121.jpg",
    "https://i.postimg.cc/9FbV58b7/129.jpg",
    "https://i.postimg.cc/bJpYt3x0/Arcioni.jpg",
    "https://i.postimg.cc/HLF19j4Y/80.jpg",
    "https://i.postimg.cc/HsM3PzD1/112.jpg",
    "https://i.postimg.cc/J0gWPqk2/Marcone.jpg",
    "https://i.postimg.cc/J4MmFVN8/131.jpg",
    "https://i.postimg.cc/jdmsXs6S/Casa-del-Dr-P-ndola-D-az.jpg",
    "https://i.postimg.cc/MGbqqVCn/horne-2.jpg",
    "https://i.postimg.cc/ncKVVKKv/88.jpg",
    "https://i.postimg.cc/nLtpy0P8/castro.jpg",
    "https://i.postimg.cc/nLXKvWMb/120.jpg",
    "https://i.postimg.cc/nrMJ45Cm/hornne.jpg",
    "https://i.postimg.cc/QNw0bPzq/90.jpg",
    "https://i.postimg.cc/qR1rC0M0/horne.jpg",
    "https://i.postimg.cc/T2HGdR4J/Masvernat.jpg",
    "https://i.postimg.cc/TP334yDn/116.jpg",
    "https://i.postimg.cc/vBYMBDy3/horne-3.jpg",
    "https://i.postimg.cc/VLF1Pf1g/98.jpg",
    "https://i.postimg.cc/vm9NMDyN/143.jpg",
    "https://i.postimg.cc/vZnG2pXL/Cobelli.jpg",
    "https://i.postimg.cc/x8d0s8Fc/cama-o.jpg",
    "https://i.postimg.cc/XJ658GS4/wqeqwe.png",
    "https://i.postimg.cc/Xvw7qTC7/Suburo.jpg"
]

headers = {
    'User-Agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/91.0.4472.124 Safari/537.36'
}

downloaded = 0
failed = 0

for i, url in enumerate(urls):
    try:
        # Limpieza básica de la URL (quitar caracteres extra al final si existen)
        url = url.strip().split(' ')[0].split('&')[0]
        
        # Generar un nombre de archivo razonable
        if "pinimg.com" in url or "postimg.cc" in url:
            filename = url.split('/')[-1]
            if not filename.endswith(('.jpg', '.png', '.jpeg')):
                filename += ".jpg"
        else:
            filename = f"foto_{i}.jpg"
            
        filepath = os.path.join(output_dir, filename)
        
        # Evitar duplicados si el nombre es el mismo
        if os.path.exists(filepath):
            filename = f"{i}_{filename}"
            filepath = os.path.join(output_dir, filename)

        print(f"Descargando ({i+1}/{len(urls)}): {url}")
        response = requests.get(url, headers=headers, timeout=15)
        
        if response.status_code == 200:
            with open(filepath, 'wb') as f:
                f.write(response.content)
            downloaded += 1
        else:
            print(f"Error {response.status_code} en {url}")
            failed += 1
            
    except Exception as e:
        print(f"Excepción descargando {url}: {str(e)}")
        failed += 1

print("\n" + "="*30)
print(f"Proceso finalizado.")
print(f"Descargas exitosas: {downloaded}")
print(f"Fallidas: {failed}")
print(f"Carpeta: {output_dir}")
print("="*30)
