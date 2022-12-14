# PoshStrava
## about_PoshStrava

```
ABOUT TOPIC NOTE:
about_PoshStrava

# SHORT DESCRIPTION
PowerShell Module build on top of the Strava API v3

```
ABOUT TOPIC NOTE:
You will need a Strava Account and you will need to have an API app setup to be able to authenticate with this module. Read the README.md file to get started.
```

# LONG DESCRIPTION
PowerShell module for a user to authenticate and pull data from the Strava API v3.


GETTING STARTED:
To get started using this module you will need to have a strava account and an API App setup.

1. CREATING A STRAVA ACCOUNT
You can create a stava account here: https://www.strava.com/


2. CREATING A STRAVA API APP
Login to your strava account and then navigate to the URL: https://www.strava.com/settings/api and create the App


3. FINDING YOUR CLIENT ID AND SECRET ID
Once logged into strava go to 'Settings' --> 'My API Application'. Here you will see your 'Client ID' and 'Client Secret'

4. SETTING YOUR AUTHENTICATION
You will need to run the command Set-StravaAuthentication. This command will query the Api with your client information. It will then retrieve a refresh_token. This token will be used to retrieve an access_token for authentication everytime you run a command. The command Set-StravaAuthentication will create a new Microsoft PowerShell secrets vault and store the information in the vault. This way you will onlyu need to provide your password for your Secrets Store whenever you run the commands in a new PowerShell terminal.
```

# NOTE
Some of the commands will require a Strava subscription to be able to provide the data. You can check the help comments on each command to see if you need a subscription.


# SEE ALSO
[{{ Read the README file to get started }}](https://github.com/ScriptingChris/PoshStrava/blob/main/README.md)