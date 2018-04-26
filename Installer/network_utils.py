import json
import os
import platform
import shutil
import tempfile
import zipfile
import io_utils
from urllib import request
from urllib.error import HTTPError, URLError

VERSIONS_LIST_URL = "https://clarkwkw.github.io/civ5-versions.html"
TMP_SUBDIR = "GECiv5Mod"
 
def get_versions(url = VERSIONS_LIST_URL):
	opener = request.build_opener()
	try:
		version_page = opener.open(url)
	except (HTTPError, URLError):
		raise Exception("Cannot retrieve mod version info from the Internet [HTTPError/URLError]")

	version_json = json.loads(version_page.read().decode("utf-8"))
	
	return version_json

'''
The function assumes the content of the mod is zipped directly, without subdirectory
i.e. if the mod includes a file {Civ5 Dir}/Assets/123.txt , 
it should be zipped as Assets/123.txt
rather than v0.1/Assets/123.txt
'''

def download_mod(url, tmp_directory = None):
	if tmp_directory is None:
		tmpdir = "/tmp" if platform.system() == "Darwin" else tempfile.gettempdir()
	else:
		tmpdir = tmp_directory
		io_utils.make_sure_path_exists(tmpdir)

	zipdir = os.path.join(tmpdir, TMP_SUBDIR + ".zip")
	try:
		with request.urlopen(url) as response, open(zipdir, "wb") as out_file:
			shutil.copyfileobj(response, out_file)
	except (HTTPError, URLError):
		raise Exception("Cannot download the mod from the Internet [HTTPError/URLError]")

	except FileNotFoundError:
		raise Exception("Temporary directory is not accessible")

	try:
		if os.path.exists(os.path.join(tmpdir, TMP_SUBDIR)):
			shutil.rmtree(os.path.join(tmpdir, TMP_SUBDIR))
		with zipfile.ZipFile(zipdir, "r") as zip_ref:
			zip_ref.extractall(os.path.join(tmpdir, TMP_SUBDIR))
	except zipfile.BadZipFile:
		raise Exception("Downloaded mod content is corrupted")

	return os.path.join(tmpdir, TMP_SUBDIR)
