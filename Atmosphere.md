# Getting Started With Atmosphere 

![](http://www.cyverse.org/sites/default/files/PoweredbyCyverse_LogoSquare_0_0.png)

## Creating a Cyverse Atmosphere Account

1. Go to https://user.cyverse.org and register as a new user.
2. You must use the e-mail provided to Lisa for this workshop or your account may not be approved.
3. Once your account is activated, go to https://user.cyverse.org/dashboard and find Atmosphere under "Available Services" and click "Request Access"
4. The application will ask for the workshop name (Kew HybSeq Workshop) and Instructor name (Matt Johnson)

## Starting an Instance

Login to https://atmo.cyverse.org

From the Atmosphere dashboard, click on Projects in the blue menu bar. On the Projects page, click the `CREAET NEW PROJECT` button. Give a name and description to your project and click `CREATE`.

Once the project appears in the list, click on it to go to the Project page. From here, click the `NEW` button and select `Instance`. In the search options, select "Show all" and search for `HybPiper_Kew_Workshop`. Select the instance to view the resource allocation screen. Here is the information 

* **Base Image Version**: 1.0
* **Project**: YourProjectName
* **Provider**: Kew HybSeq Workshop 
* **Instance Size**: medium1 (CPU: 4, Mem: 8G, Disk: 80 GB)

**NOTE:** If the Kew HybSeq Workshop does not appear, select iPlant Cloud - Tuscon instead. 

Press the blue `LAUNCH INSTANCE` button. The instance will take up to 15 minutes to be fully active.


## Logging into the Instance

In the Atmosphere dashboard, navigate to Projects and select the project you created. Click on the Instance and verify that it is active. On the instance screen, under IP Address, click "copy" to copy the IP address to your clipboard.

#### MACOSX and Linux

Open the Terminal application. On MACOSX it is located in the Utilities folder inside Applications.

Enter the command:

`ssh username@127.0.0.1`

Where `username` is your Cyverse username, and `127.0.0.1` is the instance IP address. Press enter and you will be prompted your Cyverse password. Enter your password and press enter.

The first time you login you may be asked to verify the identity of the server. Type `yes` to continue.


#### Windows

Download and install PuTTY (http://www.putty.org/), an SSH client for Windows. 

Open PuTTY and open a new connection by pasting the IP address under HostName and selecting SSH. Use your Cyverse username and password.

The first time you connect, PuTTY will ask you to verify the identify of the server. Click yes.

More information about using PuTTY can be found here: https://mediatemple.net/community/products/dv/204404604/using-ssh-in-putty-



## GUI Access via VNC

The Atmosphere instance also has GUI access, which we will use to access programs with a graphical interface. You can access the server through the Web Desktop by clicking the link on the right column of instance page. However, this interface is slow, and we recommend access through a standalone program. 

Download and install VNC Viewer via https://www.realvnc.com/download/viewer/

Open the application and start a new connection from the File menu. You must connect to port 1 to access the desktop remotely. Therefore if your IP address is `127.0.0.1` you need to enter `127.0.0.1:1`. Use your Cyverse account username and password. 

Once you have connected, you should see a screen like this:

<img src=images/vnc_desktop.png width="500">

You can now access your instance as if it were any other graphical operating system. Several phylogenetics programs have been installed; view the installed programs in "Other" within the Applications menu.


## SFTP Access via Cyberduck

If you wish to transfer your own files to and from your instance, the easiest way is with a graphical SFTP client. We recommend Cyberduck (https://cyberduck.io)

Download and install Cyberduck and start a new SFTP connection with your Cyverse username, password, and instance IP address. 

You can edit files directly on your Atmosphere instance from your computer via Cyberduck. You can specify your preferred text editor in Cyberduck's preferences.

