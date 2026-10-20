# AWS VPC + EC2 Web Server (Terraform)

Builds a custom VPC on AWS from zero with Terraform and runs an nginx web server on EC2. The website file is stored in S3 and the server downloads it using an IAM role (no access keys on the server).

## Architecture

```
                    Internet
                       |
                Internet Gateway
                       |
   +-------------- VPC 10.0.0.0/16 ----------------+
   |                                               |
   |  Public subnet 10.0.1.0/24                    |
   |   +-----------------------+                   |
   |   | EC2 (nginx)           |--- IAM role ---> S3 bucket
   |   | SG: 80 open, 22 my IP |                   |  (index.html)
   |   +-----------------------+                   |
   |                                               |
   |  Private subnet 10.0.2.0/24                   |
   |   (no internet route, for a database later)   |
   +-----------------------------------------------+
```

## What gets created
| Resource | Why |
|---|---|
| VPC `10.0.0.0/16` | isolated network |
| Public subnet + route table `0.0.0.0/0 -> IGW` | makes the subnet reachable from the internet |
| Private subnet | no route to the IGW, so nothing inside is reachable from outside |
| Security group | port 80 open to everyone, SSH (22) only from my IP |
| S3 bucket (private) | stores the website file, all public access blocked |
| IAM role + instance profile | lets EC2 read only this bucket |
| EC2 `t3.micro` (Amazon Linux 2023) | installs nginx with `user_data` and copies the site from S3 |

## Deploy
```bash
terraform init
terraform apply -var="my_ip=YOUR.PUBLIC.IP/32"
```
Wait 1-2 minutes for the server to boot, then open the `website_url` output in the browser.

Delete everything after testing so you don't pay:
```bash
terraform destroy -var="my_ip=YOUR.PUBLIC.IP/32"
```

## Notes
- **Public vs private subnet**: the only difference is the route table. A subnet is "public" because its route table sends `0.0.0.0/0` to an internet gateway
- **Security group** is stateful: response traffic is allowed back automatically, so I only define inbound rules for 80 and 22
- **IAM role instead of access keys**: the EC2 gets temporary credentials from the instance profile, nothing secret is stored on the server
- Two subnets in different AZs (`a` and `b`) so it can be extended for high availability later
