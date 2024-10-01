# Obj-C Simple Tweak Login

Obj-C & PHP Login system with creating users and banning their custom UDID

## Description

This tweak gives users the freedom to create their own usernames and passwords but allows you to regulate it all and ban if needed

## Getting Started

### Dependencies

* 000webhost web server
* MySQL Database
* Theos

### Setting Up

* Upload login.php and register.php from the PHP folder to your web server
* Copy and paste your database username, name and password into the top of both files
```
$dbUsername = ""; 
$dbPassword = "";
$dbname = "";
```
* Copy and paste users.sql and banned_devices.sql into your database to create the tables
* Cange both links to the web server in the Tweak.xm to your own
```
[request setURL:[NSURL URLWithString:@"https://webserver.com/login.php"]];
[request setURL:[NSURL URLWithString:@"https://webserver.com/register.php"]];
```
* Compile project using theos
* Inject into app with sideloadly

## Version History

* 0.1
    * Initial Release
