from setuptools import setup, find_packages

setup(
    name="gymtrack",
    version="0.1.0",
    description="A minimalist, click-and-go workout tracker.",
    author="Group 7",
    packages=find_packages(),  # Automatically finds the 'gymtrack' folder
    install_requires=[
        "matplotlib",
        "numpy",
        # tkinter is standard in Python, so we don't list it here
    ],
    entry_points={
        'console_scripts': [
            'gymtrack=gymtrack:main',  # This makes the command 'gymtrack' work in terminal
        ],
    },
    python_requires='>=3.6',
)