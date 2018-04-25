import tkinter as tk
from tkinter import filedialog
import io_utils, network_utils
import platform
import shutil, os
from multiprocessing import Process, Manager, Queue
from queue import Empty

TEST_MODE = True
VERSION_DICT = {}
queue = Queue()

class ModInstaller(tk.Tk):
	def __init_vars(self):
		self.var_civ5_path = tk.StringVar("")
		self.var_chosen_ver = tk.StringVar("")
		self.var_civ_status = tk.StringVar("")
		self.var_installed_mod_ver = tk.StringVar("")
		self.var_status_msg = tk.StringVar("")

	def browse_button(self):
		initialdir = self.var_civ5_path.get() if self.var_civ5_path.get() is not None else None
		filename = filedialog.askdirectory(initialdir = initialdir)
		if filename is not None and len(filename) > 0:
			self.var_civ5_path.set(filename)
			self.update_label_civstatus()
			self.update_label_modver()

	def update_version_menu(self, options):
		self.version_menu["menu"].delete(0, "end")
		for version in options:
			self.version_menu["menu"].add_command(label = version)

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
		else:
			self.modver_val.config(fg = "red")
			self.var_installed_mod_ver.set("Not detected")

	def update_status_msg(self, msg = "", is_err = False):
		if is_err:
			self.status_label.config(fg = "red")
		else:
			self.status_label.config(fg = "grey")
		self.var_status_msg.set(msg)

	def install(self):
		def install_helper(queue):
			civ5_path = self.var_civ5_path.get()
			if not io_utils.verify_civ5_installation_path(civ5_path):
				self.update_status_msg("Cannot detect Civ5 installation, please check installation path.", True)
				return

			chosen_ver = self.var_chosen_ver.get()
			if chosen_ver not in VERSION_DICT["versions"]:
				queue.put(("Invalid version config.", True))
			else:
				try:
					mod_url = VERSION_DICT["versions"][chosen_ver]["url"]
					queue.put(("Downloading...", ))
					downloaded_dir = network_utils.download_mod(mod_url)

					queue.put(("Installing...", ))
					install_path = civ5_path + "/" + io_utils.CIV5_ROOT_OFFSET[platform.system().lower()]
					io_utils.merge_dir(downloaded_dir, install_path)

					queue.put(("Removing temporary files...", ))
					shutil.rmtree(downloaded_dir)
					os.remove(downloaded_dir + ".zip")

					queue.put(("Done.", ))

				except Exception as e:
					queue.put((str(e), True))

		def update_status_helper():
			try:
				while True:
					args = queue.get(block = False)
					self.update_status_msg(*args)
			except Empty:
				pass

			if self.install_process.is_alive():
				self.after(20, update_status_helper)
			else:
				self.install_button.config(state = tk.NORMAL)

		self.install_button.config(state = tk.DISABLED)
		self.update_status_msg("")
		self.install_process = Process(target = install_helper, args = (queue, ))
		self.install_process.start()
		self.after(20, update_status_helper)

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

		global version_menu
		self.version_menu = tk.OptionMenu(self.win, self.var_chosen_ver, [])
		self.version_menu.configure(justify = "center")
		version_val = tk.Label(self.win, textvariable = self.var_chosen_ver)
		if TEST_MODE:
			self.version_menu.grid(column = 1, row = 4, sticky = "ew")
		else:
			version_val.grid(column = 1, row = 4)

		# Status message label
		self.status_label = tk.Label(self.win, textvariable = self.var_status_msg)
		self.status_label.grid(column = 0, row = 5, columnspan = 3, sticky = "w")

		# Buttons
		self.install_button = tk.Button(self.win, text = "Install", command = self.install)
		self.install_button.grid(column = 1, row = 6, sticky = "ew")

		global VERSION_DICT
		try:
			VERSION_DICT = network_utils.get_versions()
			self.update_version_menu(list(VERSION_DICT["versions"].keys()))
			self.var_chosen_ver.set(VERSION_DICT["current_version"])
		except Exception as e:
			self.update_status_msg(str(e), True)
			self.install_button.config(state = tk.DISABLED)

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
			

if __name__ == "__main__":
	try:
		with open("civ5_test_mode.txt", "r") as f:
			pass
		TEST_MODE = True
	except:
		TEST_MODE = False
	installer = ModInstaller()
	installer.mainloop()
