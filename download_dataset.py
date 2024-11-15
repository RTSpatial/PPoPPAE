import sys
from onedrivedownloader import download

link = sys.argv[1]
out = sys.argv[2]

download(link, filename=out, unzip=False, force_download=True)
