#!/usr/bin/env python3

import os
import re
from pathlib import Path
from setuptools import setup
try:
	from cx_Freeze import setup, Executable
	cx_Freeze = True
except ImportError as e:
	cx_Freeze = False

basedir = Path(__file__).parent.absolute()

isWindows = os.name.lower() == "nt"

extraKeywords = {}

# Create freeze executable list.
if cx_Freeze:
	extraKeywords["executables"] = [
		Executable(script="piccol",
			   base=("Win32GUI" if isWindows else None)),
	]
	extraKeywords["options"] = {
		"build_exe" : {
			"packages" : [],
			"excludes" : [
				"PyQt5.QtCore", "PyQt5.QtGui", "PyQt5.QtWidgets",
				"PySide2.QtCore", "PySide2.QtGui", "PySide2.QtWidgets",
				"tkinter",
				"test", "unittest",
			],
		},
	}

# Get version.
with open(basedir / "piccol", "rb") as fd:
	m = re.match(r'.*^\s*PICCOL_VERSION\s*=\s*"([\w\d\.\-_]+)"\s*$.*',
		     fd.read().decode("UTF-8"),
		     re.DOTALL | re.MULTILINE)
	assert m
	version = m.group(1)
print("piccol version %s" % version)

# Get readme text.
with open(basedir / "README.md", "rb") as fd:
	readmeText = fd.read().decode("UTF-8")

setup(
	name		= "piccol",
	version		= version,
	description	= "Color picker and translator",
	license		= "GNU General Public License v2 or later",
	author		= "Michael Büsch",
	author_email	= "m@bues.ch",
	url		= "https://bues.ch/",
	scripts		= [ "piccol", ],
	keywords	= [ "color", "RGB", "HLS", "HSL", ],
	install_requires = [ "PyQt6", ],
	python_requires	= ">=3.7",
	classifiers	= [
		"Development Status :: 5 - Production/Stable",
		"Environment :: Win32 (MS Windows)",
		"Environment :: X11 Applications",
		"Environment :: X11 Applications :: Qt",
		"Intended Audience :: End Users/Desktop",
		"Intended Audience :: Developers",
		"Intended Audience :: Education",
		"Intended Audience :: Information Technology",
		"Intended Audience :: System Administrators",
		"License :: OSI Approved :: GNU General Public License v2 or later (GPLv2+)",
		"Operating System :: Microsoft :: Windows",
		"Operating System :: POSIX",
		"Operating System :: POSIX :: Linux",
		"Programming Language :: Python",
		"Programming Language :: Python :: 3",
		"Programming Language :: Python :: Implementation :: CPython",
		"Topic :: Desktop Environment",
		"Topic :: Education",
		"Topic :: Scientific/Engineering",
		"Topic :: Software Development",
	],
	long_description=readmeText,
	long_description_content_type="text/markdown",
	**extraKeywords
)
