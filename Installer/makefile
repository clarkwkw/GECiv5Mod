pyver_mac = 3
pyver_win = 
mac:
	python$(pyver_mac) compile.py bdist_mac --custom-info-plist Info.plist
	mv build/*.app ./
	rm -rf build
win:
	python$(pyver_win) compile.py build_exe
clean:
	rm -rf build