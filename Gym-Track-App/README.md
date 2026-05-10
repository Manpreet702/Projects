# gym_track_app

Do you like working out? 

Are you tired of keeping a log book regarding your PRs and resp and sets?

This app is for YOU!!!


Presentation file: https://docs.google.com/presentation/d/1vor3T5MMKLoAqIq70TIpxJmpTJ9p3SA7yGH9O2Ao_cQ/edit?usp=sharing


# How to Use the App

Follow these steps to set up the database, configure the application, and run it on your local system.

## 1. Import the Database

First, ensure you have the `database.sql` file downloaded.

**Steps to import using MySQL Workbench:**

1.  Open **MySQL Workbench** and connect to your server.
2.  Go to the top menu and select **Server > Data Import**.
3.  Select **Import from Self-Contained File** and click the browse button to locate your downloaded `.sql` file.
4.  Under **Default Target Schema**, select the database you want to import into (or create a new one).
5.  Click **Start Import**.

## 2. Clone the Repository

Clone the project repository to your local system.

```bash
git clone <repository_url>


## 3. Configure the Database Connection
Once cloned, navigate to the configuration file: gymtrack > data > dbmanager.py

Open dbmanager.py in your code editor and update the DB_CONFIG dictionary to match your local MySQL settings:


DB_CONFIG = {
    'host': 'localhost',
    'database': 'gymtrack_db', # Database name used in records.sql
    'user': 'root',            # Your MySQL username
    'password': 'mysql1234'    # Your MySQL password
}


4. Install and Run
Open your terminal and navigate to the gymtrackapp directory.

Install the package:

Run the following command to install the application and dependencies:

`pip install .`

Run the app:

Once installed, you can launch the application by simply typing:

`gymtrack`