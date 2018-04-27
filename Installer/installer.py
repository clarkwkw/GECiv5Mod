import tkinter as tk
from tkinter import filedialog
import io_utils, network_utils
import platform
import shutil, os, sys
from multiprocessing import Process, Manager, Queue, freeze_support
from threading import Thread
from queue import Empty
import json
import re

TEST_MODE = True
VERSION_DICT = {}
queue = Queue()
RGX = re.compile('[_ ]')


def install_helper(civ5_path, chosen_ver, version_dict, queue):
	os_ver = platform.system().lower()
	if os_ver == "windows":
		sys.stdout = open(os.devnull, 'w')
		sys.stderr = open(os.devnull, 'w')

	if not io_utils.verify_civ5_installation_path(civ5_path):
		queue.put(("Cannot detect Civ5 installation, please check installation path.", True))
		return
	
	if chosen_ver not in version_dict["versions"]:
		queue.put(("Invalid version config.", True))
	else:
		try:
			mod_url = version_dict["versions"][chosen_ver]["url"]
			queue.put(("Downloading...", ))
			downloaded_dir = network_utils.download_mod(mod_url)

			queue.put(("Backing up files...", ))
			with open(os.path.join(downloaded_dir, "Assets/DLC/MP_MODSPACK/modinfo.json"), "r") as f:
				modinfo = json.load(f)

			for file in modinfo["files_replaced"]:
				try:
					full_path = os.path.join(civ5_path, io_utils.CIV5_ROOT_OFFSET[os_ver], file)
					os.rename(full_path, full_path + ".bak")
				except IOError as e:
					pass

			queue.put(("Installing...", ))
			install_path = os.path.join(civ5_path, io_utils.CIV5_ROOT_OFFSET[platform.system().lower()])
			io_utils.merge_dir(downloaded_dir, install_path)

			queue.put(("Removing temporary files...", ))
			shutil.rmtree(downloaded_dir)
			os.remove(downloaded_dir + ".zip")

			queue.put(("Installed.", ))

		except Exception as e:
			queue.put((str(e), True))

def uninstall_helper(civ5_path, queue):
	os_ver = platform.system().lower()
	if os_ver == "windows":
		sys.stdout = open(os.devnull, 'w')
		sys.stderr = open(os.devnull, 'w')
	civ5_path = os.path.join(civ5_path, io_utils.CIV5_ROOT_OFFSET[os_ver])

	queue.put(("Removing files...", ))

	with open(os.path.join(civ5_path, "Assets/DLC/MP_MODSPACK/modinfo.json"), "r") as f:
		modinfo = json.load(f)

	for path in modinfo["files_copied"]:
		full_path = os.path.join(civ5_path, path)
		try:
			if os.path.isdir(full_path):
				shutil.rmtree(full_path)
			else:
				os.remove(full_path)
		except (IOError, FileNotFoundError):
			pass

	queue.put(("Restoring files...", ))

	for file in modinfo["files_replaced"]:
		full_path = os.path.join(civ5_path, file)
		try:
			os.remove(full_path)
		except IOError as e:
			pass

		try:
			os.rename(full_path + ".bak", full_path)
		except IOError as e:
			pass

	queue.put(("Uninstalled.", ))

class ModInstaller(tk.Tk):
	def __init_vars(self):
		self.var_civ5_path = tk.StringVar("")
		self.var_chosen_ver = tk.StringVar("")
		self.var_civ_status = tk.StringVar("")
		self.var_installed_mod_ver = tk.StringVar("")
		self.var_status_msg = tk.StringVar("")
		self.var_button_text = tk.StringVar("")

		self.var_civ5_path.trace('w', self.check_test_mode)

	def browse_button(self):
		initialdir = self.var_civ5_path.get() if self.var_civ5_path.get() is not None else None
		filename = filedialog.askdirectory(initialdir = initialdir)
		if filename is not None and len(filename) > 0:
			self.var_civ5_path.set(filename)
			self.update_label_civstatus()
			self.update_label_modver()

	def update_version_menu(self, options):
		def switch_version_helper(version):
			self.var_chosen_ver.set(version)

		self.version_menu["menu"].delete(0, "end")
		for version in options:
			self.version_menu["menu"].add_command(label = version, command = lambda: switch_version_helper(version))

	def update_label_civstatus(self):
		civ5_path = self.var_civ5_path.get()
		if io_utils.verify_civ5_installation_path(civ5_path):
			self.civstatus_val.config(fg = "green")
			self.var_civ_status.set("Installed")
		else:
			self.civstatus_val.config(fg = "red")
			self.var_civ_status.set("Not detected")

	def update_label_modver(self):
		civ5_path = self.var_civ5_path.get()
		modver = None

		if io_utils.verify_civ5_installation_path(civ5_path):
			modver = io_utils.check_mod_version(civ5_path)

		if modver is not None:
			self.modver_val.config(fg = "green")
			self.var_installed_mod_ver.set(modver)
			self.var_button_text.set("Uninstall")
		else:
			self.modver_val.config(fg = "red")
			self.var_installed_mod_ver.set("Not detected")
			self.var_button_text.set("Install")

	def update_status_msg(self, msg = "", is_err = False):
		if is_err:
			self.status_label.config(fg = "red")
		else:
			self.status_label.config(fg = "grey")
		self.var_status_msg.set(msg)

	def update_status_tracker(self):
		try:
			args = queue.get(block = False)
			self.update_status_msg(*args)
		except Empty:
			pass

		if self.install_process.is_alive() or not queue.empty():
			self.after(20, self.update_status_tracker)
		else:
			self.install_button.config(state = tk.NORMAL)
			self.update_label_modver()

	def check_test_mode(self, a, b, c):
		parsed_cmd = RGX.sub('', self.var_civ5_path.get().lower())
		if parsed_cmd == "testmode=true":
			self.version_menu.grid()
			self.version_val.grid_remove()
		elif parsed_cmd == "testmode=false":
			self.version_menu.grid_remove()
			self.version_val.grid()
		else:
			return

		civ5_path = io_utils.suggest_civ5_installation_path()
		self.var_civ5_path.set("" if civ5_path is None else civ5_path)

	def install(self):
		if io_utils.check_mod_version(self.var_civ5_path.get()) is not None:
			self.uninstall()
			return

		self.install_button.config(state = tk.DISABLED)
		self.update_status_msg("")
		self.install_process = Process(target = install_helper, args = (
														self.var_civ5_path.get(), 
														self.var_chosen_ver.get(), 
														VERSION_DICT,
														queue))
		self.install_process.daemon = True
		self.install_process.start()
		self.after(20, self.update_status_tracker)

	def uninstall(self):
		self.install_button.config(state = tk.DISABLED)
		self.update_status_msg("")
		self.install_process = Process(target = uninstall_helper, args = (self.var_civ5_path.get(), queue))
		self.install_process.daemon = True
		self.install_process.start()
		self.after(20, self.update_status_tracker)

	def download_mod_version_dict(self):
		self.update_status_msg("Retrieving available versions..")
		self.install_button.config(state = tk.DISABLED)
		try:
			global VERSION_DICT
			VERSION_DICT = network_utils.get_versions()
			self.update_version_menu(list(VERSION_DICT["versions"].keys()))
			self.var_chosen_ver.set(VERSION_DICT["current_version"])
			self.install_button.config(state = tk.NORMAL)
			self.update_status_msg("Retrieved.")
		except Exception as e:
			self.update_status_msg(str(e), True)		

	def clearup(self):
		if self.install_process is not None and self.install_process.is_alive():
			self.install_process.terminate()
		self.destroy()

	def __init__(self, *args, **kwargs):
		tk.Tk.__init__(self, *args, **kwargs)
		self.install_process = None
		
		self.win = tk.Frame(self)
		self.title("Civ 5 Mod Installer")
		self.win.grid(padx = 10, pady = 10)

		self.__init_vars()

		# Heading
		heading_label = tk.Label(self.win, text = "Civ 5 Mod Installer", font = "Helvetica 15 bold")
		heading_label.grid(column = 0, row = 0, sticky = "w")

		# Installation Path
		path_label = tk.Label(self.win, text = "Installation Path", font = "Helvetica 13 bold")
		path_label.grid(column = 0, row = 1, sticky = "w")

		path_input = tk.Entry(self.win, textvariable = self.var_civ5_path)
		path_input.grid(column = 1, row = 1)
		path_input.bind("<Control-KeyRelease-a>", select_all_callback)
		path_input.bind("<Command-KeyRelease-a>", select_all_callback)

		path_button = tk.Button(self.win, text = "Browse", command = self.browse_button)
		path_button.grid(column = 2, row = 1)

		# Civ5 status Label
		civstatus_label = tk.Label(self.win, text = "Civ 5 Status", font = "Helvetica 13 bold")
		civstatus_label.grid(column = 0, row = 2, sticky = "w")

		self.civstatus_val = tk.Label(self.win, textvariable = self.var_civ_status)
		self.civstatus_val.grid(column = 1, row = 2)

		# Mod version label
		modver_label = tk.Label(self.win, text = "Patch Installed", font = "Helvetica 13 bold")
		modver_label.grid(column = 0, row = 3, sticky = "w")

		self.modver_val = tk.Label(self.win, textvariable = self.var_installed_mod_ver)
		self.modver_val.grid(column = 1, row = 3)

		# Latest mod version
		version_label = tk.Label(self.win, text = "Latest Version", font = "Helvetica 13 bold")
		version_label.grid(column = 0, row = 4, sticky = "w")

		self.version_menu = tk.OptionMenu(self.win, self.var_chosen_ver, *[""])
		self.version_menu.configure(justify = "center")
		self.version_menu.grid(column = 1, row = 4, sticky = "ew")
		self.version_menu.grid_remove()

		self.version_val = tk.Label(self.win, textvariable = self.var_chosen_ver)
		self.version_val.grid(column = 1, row = 4)

		# Status message label
		self.status_label = tk.Label(self.win, textvariable = self.var_status_msg)
		self.status_label.grid(column = 0, row = 5, columnspan = 3, sticky = "w")

		# Buttons
		self.install_button = tk.Button(self.win, textvariable = self.var_button_text, command = self.install)
		self.install_button.grid(column = 1, row = 6, sticky = "ew")

		retrieve_modver_thread = Thread(target = self.download_mod_version_dict)
		retrieve_modver_thread.start()
		
		civ5_path = io_utils.suggest_civ5_installation_path()
		if civ5_path is not None:
			self.var_civ5_path.set(civ5_path)

		self.update_label_modver()
		self.update_label_civstatus()
		self.protocol("WM_DELETE_WINDOW", self.clearup)

		col_count, row_count = self.win.grid_size()
		for row in range(row_count):
			self.win.grid_rowconfigure(row, minsize = 30)

		self.win.grid_columnconfigure(0, minsize = 110)
		self.win.grid_columnconfigure(2, minsize = 110)

# Adapt from: https://stackoverflow.com/questions/41477428/ctrl-a-select-all-in-entry-widget-tkinter-python
def select_all_callback(event):
	event.widget.select_range(0, 'end')
	event.widget.icursor('end')

if __name__ == "__main__":
	freeze_support()
	installer = ModInstaller()
	installer.resizable(False, False)
	installer.mainloop()

