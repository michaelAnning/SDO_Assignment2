# Servian TechTestApp

Issue:
- Everything's deployed manually using ClickOps.
	* Prone to human error.
- Want you to use AWS EC2 to host their application online.

## dependencies

- AWS: Where all our resources will be stored. In order to communicate with the AWS console, we must create an AWS session & store its credentials/keys on our local computer. That way, terraform can directly communicate with AWS.

	- First off, you must create a session with AWS by logging into our AWS.
	- Click the account details button. This will display a list of keys needed to connect your local device to the AWS session.
	- Before that, you must create a place on our computer to store these keys.
	- In your home directory, either create or locate a folder called '.aws' then open it.
	- Create/locate the 'credentials' file (no file type) & paste the keys in.
	
	- Warning: Be aware that after every 3 hours, the credentials will be considering invalid as the session has expired. You'll need to create a new session on AWS & store the credentials from that.

- terraform: Setups the computer's internals. Before Terraform can communicate with AWS via the credientials, it must first connect to AWS's API. That way, any commands it runs will be translated into the language the AWS Console recognises. We do this by assigning terraform a provider, the same as an API.

	- In a tf file, define a provider resource for AWS.
	- A provider only needs to contain the region our infrastructure will belong to, & the version of AWS you'll use.

- ansible: Runs the computer & its procedures for you.
- makefile: Calls commands to automate the deployment procedure.

Terraform Usage:

- Terraform is folder specific. That means when you run a terraform command in one folder, it will only search for config files relevant to that folder (no sub-folder).
- This will be helpful in allowing us to create certain infrastructure needed to create others. You'll explore this when discussing Remote Backends.
- Terraform mainly uses two file types: .tf files & tfstate files.
- .tf files are local config files. They dictate the type of resources you want managed by AWS. You can have many .tf files in one folder.
- .tfstate files represent our remote setups. They're populated based on the resources defined in our .tf files, and reference the infrastructure Terraform creates in our AWS Console. Created automatically by Terraform. One per folder.

## deploy instructions

To make things easy for users to deploy this app, you'll be taking advantage of something called a 'makefile'. The one in the root directory of the project.

Essentially, a make file containers identifiers that, when called, execute a set of commands within your terminal. These terminal commands will be responsible for both creating & deploying the app, as well as destroying all resources later on (we'll address this later).

If we didn't have the makefile, you'd be responsible for entering every single linux command needed, in the right order, to deploy our app. These commands sometimes require information you won't have access to, such as values referring to a S3 Bucket & DynamoDB table. If you did have the information, however, and try to input it correctly, there's a chance of wrong input, causing the deployment process to falter.

Instead of memorise a multitude of commands to do one thing, commands you're likely to input correctly cause of human failure, all you need is to call one identifier in a makefile. Much easier.

- Using Makefiles

In short, to deploy the app, travel to your project's root directory in a terminal environment (cd [directory]/[directory]/[project_name]) and run the terminal command 'make start'. This will run a series of commands in your terminal automatically, responsible for developing & deploying the resources needed to host your app on the internet.

Makefiles are manipulated via a make command. They follow this format: 'make [identifier]'. You substitute the identifier part for a relevant id in the makefile. You can inspect the ids by opening the makefile in a text editor.

For example, as illustrated in this image:

![alt text](http://url/to/makefile_start.png)

We have an identifier called 'start'. Referring to our format, we would replace '[identifier]' with 'start' to have the makefile call the commands pre-defined within it.

One thing you may notice that all the commands defined in 'start' are actually other makefile identifiers. This may seem strange and like it shouldn't work, but remember: All makefiles' do is feed commands into your terminal automatically. 'terraform apply' is no different then 'make stop1' in a terminal activation sense. Having it setup like this just allows the deployment process to be further streamlined, and less likely to fail due to inputting commands in the wrong order.

Remember, to correctly take advantage of a makefile, you must do the following within a terminal:
1. Change the directory so you're in one with the makefile. In this case, cd into the root directory of the project.
2. Call an existing makefile identifier. If you call an ID that doesn't exist, the makefile will return an error and do nothing else.

If you'd like to ssh into your EC2 after 'make start' finishes running, enter 'make ec2' into your terminal. From there, you can inspect the remote host's setup and make any changes needed (this isn't required, as everything will be preset up as needed).

- What This All Does

'make start' will utilise the services of both Terraform & Ansible, using terraform to develop our app's infrastructure, and then Ansible to update our EC2 instance containing our application. Think of Terraform as the automated equivalent of setting up both our application and an environment it can run on (the Amazon EC2). Then, Ansible automates turning on all components in our environment, so the app can be accessed via the internet.

![alt text](http://url/to/make_start.png)

- Setting Up Components for the Remote Backend

The first thing 'make start' will do is develop parts of a remote backend for our terraform state to run on. It will create two specific things: An Amazon S3 Bucket & a DynamoDB_Table. The .tf file creating these is actually located in a separate folder to the other .tf files. This is because the command run to create these resources, 'terraform apply', parses every .tf file in a folder at once. In this case, we don't want that, as the backend needs to produce a 'randomstring.txt' file. This file will contain data used for initialising our project with the remote backend.

S3, otherwise known as Amazon Simple Storage Service, is an AWS feature allowing you to store projects in a cloud, such as our one. 

DynamoDB is an NoSQL database, which our application can connect to to store data. DynamoDB utilises state locking, a feature to prevent multiple people from updating the database at the same time. The database we define in our later configurations will be associated with this.

After 'cd infra/backend && terraform apply', the resources will be created, and our required 'randomstring.txt' will be produced. The 6-lettered string found within will represent the id of both the S3 Bucket & DynamoDB_Table. 

![alt text](http://url/to/backend_random.png)

![alt text](http://url/to/backend_setup.png)

- Linking our Terraform Setup with the Remote Backend

Now with that created, 'make start' initializes the main terraform.tfstate file used for the rest of the project. The remote backend defined in the 'main.tf' folder will be fed the ids of both the S3 Bucket & DynamoDB_Table, instructing where the application's main '.tfstate' file will be located: Remotely on your Amazon S3 bucket in the AWS Console.

![alt text](http://url/to/makefile_start2.png)

- Automating our Application Infrastructure's Creation

Once finished, the rest of the entire application is produced via an automatic 'cd infra && terraform apply' command. A 'terraform.tfstate' will be created linking our project with all the remote resources developed, and that tfstate will be stored in the Amazon S3 bucket.

- Turning on Our Online Environment

The main feature created above is a EC2. An EC2 is an emulation of a computer environment, capable of running applications on it from a remote host. Despite terraform creating the EC2, there's currently nothing on it to run. That's because while Terraform has created the EC2, it hasn't provided it with the actual app, or the means to turn it on. That's where Ansible steps in.

Ansible itself is responsible for configuring the environment within our EC2. It utilises two types of files: inventories & playbooks. A playbook is a set of task that must be run on a remote host, while an inventory contains references to the remote hosts to manipulate. Both instances are yml files & use the yaml language strucuture. 

Terraform has produced an inventory.yml file in our Ansible file, containing the IP of our EC2. We'll run our playbook.yml file against the host located here.

- Downloading & Installing the App onto the Remote Host

First thing Ansible does is download the application we need from GitHub, in this case being a linux release of Servian Test App ( https://github.com/servian/TechTestApp/releases ) onto the remote host. As it's a zip file downloaded, Ansible then extracts the contents of the zip file.

![alt text](http://url/to/ansible_play1.png)

- Turning on the Environment & App

The app's now downloaded, but that doesn't mean it's accessible via the internet. This is because its not turned on. The remote host requires a .service file located in its 'etc/systemd/system' directory. This service file will handle turning on the app and making it accessible via an IP address.

Terraform has already created a .service file that achieves the above. Since it's stored locally, Ansible will transfer the file over to our remote host's 'etc/systemd/system' directory.

Before the service is activated, Ansible first updates the remote app's database config with the values of our terraform created database. This is so the app's database connects directly to our own, and handles all database queries through it. Once done, we know restart the service to cement the updates we've made to our app.

Once restarted, Ansible's now prepared to startup our app. It will ensure the .service file has already started, and if not, turn it on. Then it will reload the daemon_connection, essentially allowing the changes made to be visible when we use a browser to connect to the EC2's ip. With that, our application is now internet accessible.

![alt text](http://url/to/ansible_play2.png)

- Updating the Database

While accessible, we still have a major issue with the app. The app itself is a todo-list software, and it relies on a database to store tasks & list them on the website. However, if you only do the above, all that'll be visible is the servian webpage with a list of tasks all reading 'Now Loading'. That means the database isn't operation.

![alt text](http://url/to/servian_nodb.png)

The reason for this is because the app's database isn't currently able to hold data. While we have config it so it connects to our database, we still haven't activated our database. To fix this, Ansible runs the command './TechTestApp updatedb -s', which fully links the AWS db with the remote app's. As a result, it creates tables based on the setup of the AWS db, and can now send queries towards it. With that done, our application is fully deployed.

![alt text](http://url/to/ansible_updatedb.png)

![alt text](http://url/to/servian_db.png)

## cleanup instructions

Cleanup's as easy as deploying the app. Another makefile identifer called 'stop' exists within the root directory's makefile, essentially telling Terraform to delete every resource we've already created. We do this to save on credit.

In short, call 'make stop' on the project's root directory.

![alt text](http://url/to/makefile_stop.png)

- The Process'

Put simply, 'make stop' will tell Terraform to delete all our resources in the opposite order they were created. Or rather, what was created last is the first to be deleted, and so on. It calls the 'terraform destroy' command to achieve this.

An extra thing done here not handled by 'terraform destroy' is the destruction of the 'project/infra/.terraform.tfstate' file. It not destroyed, this would create issues in defining a new statefile to be stored on the S3 bucket. It's recommended to be done this way, as there's no real way to get around this issue other than deleting the file entirely.

![alt text](http://url/to/makefile_stop3.png)