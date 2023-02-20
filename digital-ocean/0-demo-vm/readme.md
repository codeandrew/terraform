# Digital Ocean Terraform


## Get Digital Ocean Token

To get a DigitalOcean token, you can follow these steps:

- Log in to your DigitalOcean account.
- Click on the "API" tab in the left-hand menu.
- Click on the "Generate New Token" button.
- Enter a name for your token (optional) and select the scopes you want to grant it.
- Click on the "Generate Token" button.
- Copy the generated token and save it somewhere safe.
- You can then use this token in your Terraform code to authenticate with DigitalOcean.


## Run

- Open a terminal window and navigate to the directory where you saved main.tf.
- Run terraform init to initialize the working directory.
- Run terraform plan to preview the changes that Terraform will make.
- If the plan looks good, run terraform apply to create the Droplet.
- Wait for Terraform to finish provisioning the Droplet.
- When Terraform is done, it will output the IP address of the Droplet. You can use this IP address to SSH into the Droplet and verify that the hello.txt file was created.

