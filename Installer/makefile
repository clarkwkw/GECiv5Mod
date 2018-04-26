pyver_mac = 3
pyver_win = 
mac:
	python$(pyver_mac) compile.py bdist_mac --custom-info-plist Info.plist
	mv build/*.app ./
	rm -rf build
windows:
	pyinstaller installer.py --onefile --noconsole
	mv dist/installer.exe ./
	rm -rf build dist
	rm -f installer.spec
clean:
	rm -rf build dist
	rm -f installer.spec