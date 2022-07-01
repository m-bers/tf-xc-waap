# F5 Distributed Cloud Terraform Personal Lab

Welcome to my terraform lab! 

The purpose of this project is to, in a single terraform run, apply VPC/EC2 infrastructure in AWS with two applications: The OWASP Juice Shop and The F5 Arcadia Application, with Web Application and API Protection policies via F5 Distributed Cloud (F5 XC) that integrate existing knowledge of an API (in the form of a `swaggerfile`) and also tie into F5 XC's ability to discover another API without an already specified definition: [API Endpoint - Discovery & Control](https://docs.cloud.f5.com/docs/how-to/app-security/apiep-discovery-control).

# Getting Started

You will need an AWS account. This spins up 