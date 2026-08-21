# Student Management System — AWS DevOps

A cloud-based Student Management System built to demonstrate AWS serverless architecture, Infrastructure as Code (Terraform), container-free application deployment, GitHub Actions CI/CD, and secure GitHub-to-AWS authentication using OpenID Connect (OIDC).

The application provides CRUD operations for student records and uses Amazon API Gateway, AWS Lambda, and Amazon DynamoDB for the backend. The React frontend is hosted on Amazon S3 and distributed through Amazon CloudFront.

The project was later extended with a complete GitHub Actions CI/CD pipeline so that changes pushed to the `main` branch are automatically built and deployed to AWS.

---

## Table of Contents

- [Project Overview](#project-overview)
- [Architecture](#architecture)
- [Technologies Used](#technologies-used)
- [Project Structure](#project-structure)
- [Application Functionality](#application-functionality)
- [Backend Architecture](#backend-architecture)
- [Frontend Architecture](#frontend-architecture)
- [Infrastructure as Code](#infrastructure-as-code)
- [GitHub Actions CI/CD](#github-actions-cicd)
- [AWS OIDC Authentication](#aws-oidc-authentication)
- [Prerequisites](#prerequisites)
- [AWS Configuration](#aws-configuration)
- [Terraform Deployment](#terraform-deployment)
- [Backend Deployment](#backend-deployment)
- [Frontend Deployment](#frontend-deployment)
- [CI/CD Pipeline](#cicd-pipeline)
- [Testing](#testing)
- [Troubleshooting](#troubleshooting)
- [Security Considerations](#security-considerations)
- [Important Files](#important-files)
- [Recreating the Project](#recreating-the-project)
- [Lessons Learned](#lessons-learned)
- [Future Improvements](#future-improvements)

---

# Project Overview

The Student Management System is a serverless web application that allows users to manage student records.

The system supports:

- Creating students
- Viewing students
- Updating students
- Deleting students

Each student record contains:

- `studentId`
- `name`
- `department`
- `level`
- `email`

The backend is completely serverless and uses AWS Lambda and DynamoDB.

The frontend is a React application hosted on Amazon S3 and served through Amazon CloudFront.

The infrastructure is managed using Terraform, while GitHub Actions automates the deployment process.

---

# Architecture

The application follows this architecture:

```text
                         GitHub Repository
                                |
                                | git push
                                v
                       +-------------------+
                       |  GitHub Actions   |
                       +-------------------+
                                |
                                | OIDC
                                v
                       +-------------------+
                       |    AWS IAM Role   |
                       +-------------------+
                                |
                     +----------+----------+
                     |                     |
                     v                     v
                Terraform              Frontend
                Deployment                Build
                     |                     |
                     |                     v
                     |                    S3
                     |                     |
                     |                     v
                     |                CloudFront
                     |                     |
                     |                     v
                     |                React App
                     |                     |
                     |                API Requests
                     |                     |
                     v                     v
                AWS Resources        API Gateway
                                           |
                                           v
                                        Lambda
                                           |
                                           v
                                      DynamoDB
```
Runtime Request Flow

When a user interacts with the application:

```text

Browser
   |
   v
CloudFront
   |
   v
S3
   |
   v
React Frontend
   |
   | HTTPS API Request
   v
API Gateway
   |
   v
Lambda
   |
   v
DynamoDB
```
---

Technologies Used
- Frontend
- React
- JavaScript
- HTML
- CSS
- npm
---
Backend
- AWS Lambda
- Python
- API Gateway
- Amazon DynamoDB
- Boto3
---
Infrastructure
- Terraform
- Amazon S3
- Amazon CloudFront
- AWS IAM
---
CI/CD
- GitHub Actions
- GitHub OIDC
- AWS IAM Roles
- Terraform
---
Development Tools
- Visual Studio Code
- Git
- GitHub
- AWS CLI
- Postman
- Project Structure

---

The repository is structured as follows:
```text
student-management-aws-devops/
│
├── .github/
│   └── workflows/
│       └── deploy.yml
│
├── backend/
│   ├── create_student/
│   │   └── lambda_function.py
│   │
│   ├── get_student/
│   │   └── lambda_function.py
│   │
│   ├── update_student/
│   │   └── lambda_function.py
│   │
│   └── delete_student/
│       └── lambda_function.py
│
├── frontend/
│   ├── public/
│   ├── src/
│   ├── package.json
│   ├── package-lock.json
│   └── ...
│
├── terraform/
│   ├── main.tf
│   ├── providers.tf
│   ├── variables.tf
│   ├── outputs.tf
│   ├── dynamodb.tf
│   ├── lambda.tf
│   ├── iam.tf
│   ├── api_gateway.tf
│   ├── frontend.tf
│   └── ...
│
├── .gitignore
└── README.md
```
The exact Terraform filenames may differ slightly depending on the final state of the project, but the resources are separated logically into DynamoDB, Lambda, API Gateway, IAM, frontend, provider, variables, and outputs.

#--------------------------------Application Functionality---------------------------------#

The frontend provides a simple interface for managing students.

Create Student

Users can enter:

Name, Department, Level, Email.

and click Create.

The frontend sends a request to the API Gateway endpoint.

The request reaches the Create Student Lambda function.

The Lambda function generates a unique student ID using UUID and stores the record in DynamoDB.

Example:
```
student = {
    "studentId": str(uuid.uuid4()),
    "name": body.get("name"),
    "department": body.get("department"),
    "level": body.get("level"),
    "email": body.get("email")
}
```
The record is then inserted into DynamoDB.

#---------------------------Backend Architecture-----------------------------#

The backend uses four Lambda functions to implement CRUD operations.

```text
POST   /students
   |
   v
Create Student Lambda
   |
   v
DynamoDB


GET    /students
   |
   v
Get Students Lambda
   |
   v
DynamoDB


PUT    /students/{studentId}
   |
   v
Update Student Lambda
   |
   v
DynamoDB


DELETE /students/{studentId}
   |
   v
Delete Student Lambda
   |
   v
DynamoDB
```
#---------------------------------DynamoDB---------------------------#

A DynamoDB table is used to store student records.

The primary key is:
studentId

Example item:
```
{
  "studentId": "6b3d7c7d-1234-4567-8901-abcdef123456",
  "name": "John Doe",
  "department": "Engineering",
  "level": "400",
  "email": "john@example.com"
}
```
The Lambda functions access DynamoDB using Boto3.

The table name is supplied to Lambda through an environment variable:
TABLE_NAME

This prevents the table name from being hardcoded directly into the Lambda code.

#------------------------------------API Gateway----------------------------------------------#

Amazon API Gateway provides the HTTP interface for the Lambda functions.

The API exposes endpoints similar to:
```
POST   /students
GET    /students
PUT    /students/{studentId}
DELETE /students/{studentId}
```
The API Gateway stage used during the project was:
dev

The API URL follows this pattern:
https://<api-id>.execute-api.us-east-1.amazonaws.com/dev

For example:
https://s0nebmmbzk.execute-api.us-east-1.amazonaws.com/dev/students

The API was tested independently using Postman before connecting the frontend.

#---------------------------------------Frontend Architecture--------------------------------------#

The frontend was created using React.

The React application communicates with API Gateway using HTTP requests.

The frontend uses the deployed API Gateway URL rather than localhost.

Example:
```
const API_URL =
  "https://s0nebmmbzk.execute-api.us-east-1.amazonaws.com/dev";
```
Requests are then made using:
```
fetch(`${API_URL}/students`)
```
The frontend was first tested locally and later deployed to AWS.

#--------------------------------------------S3 and CloudFront-----------------------------------#

The React production build is generated using:
```
npm run build
```
This creates the:
```
frontend/build/
```
directory.

The contents of the build directory are uploaded to an Amazon S3 bucket.

CloudFront is then used to distribute the frontend globally.

The architecture is:
```
React Build
     |
     v
S3 Bucket
     |
     v
CloudFront Distribution
     |
     v
Users
```
The CloudFront URL generated during the project was:
```
https://d2v83xiaewg4q6.cloudfront.net
```
#-------------------------------------------Infrastructure as Code----------------------------------------#

Terraform was used to provision and manage AWS infrastructure.

This allows the environment to be recreated without manually configuring every resource through the AWS Console.

Resources managed by Terraform include:

DynamoDB
Lambda
IAM roles and policies
API Gateway
S3
CloudFront
Related frontend infrastructure

Terraform commands used during development included:
terraform init, terraform validate, terraform plan, terraform apply.

To destroy the Terraform-managed infrastructure:
terraform destroy

#------------------Terraform State--------------------#

Terraform creates a state file:
terraform.tfstate

This file should not be committed to GitHub.

The .gitignore should contain:
```
terraform/.terraform/
terraform/terraform.tfstate
terraform/terraform.tfstate.backup
*.tfstate
*.tfstate.*
```

Terraform state can contain sensitive infrastructure information and should be handled carefully.

For a production implementation, the state should preferably be stored remotely in an S3 backend with appropriate locking/state protection.

#------------------GitHub Actions CI/CD---------------#

The project was extended with GitHub Actions to automate deployment.

The workflow is located at:
.github/workflows/deploy.yml

The workflow is triggered whenever code is pushed to the main branch.

```
on:
  push:
    branches:
      - main
```
The workflow performs the following operations:
```
Git Push
   |
   v
Checkout Repository
   |
   v
Authenticate with AWS using OIDC
   |
   v
Initialize Terraform
   |
   v
Terraform Validate
   |
   v
Terraform Plan
   |
   v
Terraform Apply
   |
   v
Setup Node.js
   |
   v
Install Dependencies
   |
   v
Build React Application
   |
   v
Retrieve Terraform Outputs
   |
   v
Upload Build to S3
   |
   v
Invalidate CloudFront Cache
```
#----------------GitHub Actions Workflow-------------------#

The final workflow follows this general structure:
```
name: Deploy Student Management System

on:
  push:
    branches:
      - main

permissions:
  id-token: write
  contents: read

jobs:
  deploy:
    runs-on: ubuntu-latest

    steps:

      - name: Checkout
        uses: actions/checkout@v4

      - name: Configure AWS credentials
        uses: aws-actions/configure-aws-credentials@v4
        with:
          role-to-assume: ${{ vars.AWS_ROLE_ARN }}
          aws-region: us-east-1

      - name: Setup Terraform
        uses: hashicorp/setup-terraform@v3

      - name: Terraform Init
        working-directory: terraform
        run: terraform init

      - name: Terraform Validate
        working-directory: terraform
        run: terraform validate

      - name: Terraform Plan
        working-directory: terraform
        run: terraform plan

      - name: Terraform Apply
        working-directory: terraform
        run: terraform apply -auto-approve

      - name: Setup Node.js
        uses: actions/setup-node@v4
        with:
          node-version: 24
          cache: npm
          cache-dependency-path: frontend/package-lock.json

      - name: Install frontend dependencies
        working-directory: frontend
        run: npm ci

      - name: Build frontend
        working-directory: frontend
        run: npm run build

      - name: Get infrastructure outputs
        id: terraform
        working-directory: terraform
        run: |
          echo "bucket=$(terraform output -raw s3_bucket_name)" >> "$GITHUB_OUTPUT"
          echo "distribution=$(terraform output -raw cloudfront_distribution_id)" >> "$GITHUB_OUTPUT"

      - name: Deploy frontend to S3
        run: |
          aws s3 sync frontend/build/ s3://${{ steps.terraform.outputs.bucket }} --delete

      - name: Invalidate CloudFront
        run: |
          aws cloudfront create-invalidation \
            --distribution-id ${{ steps.terraform.outputs.distribution }} \
            --paths "/*"
```
Use the exact workflow stored in the repository when recreating the project. The workflow above documents the final deployment approach used in the project.

#---------------------AWS OIDC Authentication-----------------------------#

GitHub Actions does not use long-lived AWS access keys for this project.

Instead, GitHub Actions authenticates to AWS using OpenID Connect (OIDC).

The flow is:
```
GitHub Actions
      |
      | OIDC Token
      v
AWS IAM OIDC Provider
      |
      | AssumeRoleWithWebIdentity
      v
GitHubActionsStudentManagementRole
      |
      v
AWS Resources
```
This is more secure than storing permanent AWS access keys in GitHub.

#-------------------Creating the GitHub OIDC Provider-------------------#

In AWS:
```
IAM
  → Identity providers
  → Add provider
```
Select:

Provider type:
OpenID Connect

Provider URL:
https://token.actions.githubusercontent.com

Audience:
sts.amazonaws.com

Create the provider.

#---------------------GitHub Actions IAM Role---------------#

An IAM role was created for GitHub Actions.

Example role name:

GitHubActionsStudentManagementRole

The role trust policy allows GitHub's OIDC provider to assume the role.

The trust relationship restricts access to the intended GitHub repository and branch.

Example structure:

```
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Federated": "arn:aws:iam::<ACCOUNT_ID>:oidc-provider/token.actions.githubusercontent.com"
      },
      "Action": "sts:AssumeRoleWithWebIdentity",
      "Condition": {
        "StringEquals": {
          "token.actions.githubusercontent.com:aud": "sts.amazonaws.com"
        },
        "StringLike": {
          "token.actions.githubusercontent.com:sub": "repo:<GITHUB_OWNER>/<REPOSITORY>:ref:refs/heads/main"
        }
      }
    }
  ]
}
```
The actual repository name and AWS account ID should be replaced when recreating the project.

#-----------------------GitHub Repository Variable----------------------------#

The IAM role ARN was stored as a GitHub Actions repository variable.

Navigate to
```text
GitHub Repository
→ Settings
→ Secrets and variables
→ Actions
→ Variables
```

Create:

Name:
AWS_ROLE_ARN

Value:

arn:aws:iam::<ACCOUNT_ID>:role/GitHubActionsStudentManagementRole

The workflow then references it using:

role-to-assume: ${{ vars.AWS_ROLE_ARN }}

No AWS access key or secret key is required by the GitHub Actions workflow.

Prerequisites

Before recreating this project, install:

---
- Git
- Node.js
- npm
- AWS CLI
- Terraform
- Visual Studio Code
- Postman
- An AWS account
- A GitHub account
---

Verify installations:

```
git --version
node --version
npm --version
aws --version
terraform --version
```
#---------------------------------AWS CLI Configuration-----------------------#

For local Terraform development, AWS CLI credentials were configured.

Run:
aws configure

Provide:
```
AWS Access Key ID:
<your IAM access key>


AWS Secret Access Key:
<your IAM secret key>


Default region name:
us-east-1


Default output format:
json
```
Verify the configuration:

aws configure list

Test authentication:
aws sts get-caller-identity

A successful response confirms that the AWS CLI can authenticate to the account.

#---------------------------Terraform Deployment-----------------#

Navigate to the Terraform directory:

cd terraform

Initialize Terraform:

terraform init

Validate the configuration:

terraform validate

Review the planned infrastructure:

terraform plan

Apply the infrastructure:

terraform apply

Confirm with:

yes

Terraform then creates the required AWS infrastructure.

#-------------------Backend Deployment and Testing----------------------------#

The Lambda functions implement the CRUD operations.

Each Lambda function requires the DynamoDB table name through an environment variable.

Example:

TABLE_NAME=<DynamoDB table name>

The Lambda functions were tested using Postman.

The API endpoints should be tested individually.

Create Student
POST /students

Example request body:
```
{
  "name": "John Doe",
  "department": "Engineering",
  "level": "400",
  "email": "john@example.com"
}
```
```
Get Students
GET /students
Update Student
PUT /students/{studentId}
```

Example:
```
{
  "name": "John Smith",
  "department": "Engineering",
  "level": "400",
  "email": "johnsmith@example.com"
}
```
Delete Student

DELETE /students/{studentId}

The backend was verified independently using Postman before connecting it to the frontend.

#-------------------Frontend Local Development----------------------------#

Navigate to the frontend directory:

cd frontend

Install dependencies:

npm install

Start the React development server:

npm start

The application should be available locally at:

http://localhost:3000

The frontend was tested locally before deployment.

#-----------------------------Building the Frontend-------------------------------#

Create a production build:

npm run build

The command generates:

frontend/build/

The build contains the production HTML, JavaScript, CSS, and other static assets.

The build directory is what gets deployed to S3.

#---------------------------------CI/CD Deployment---------------------------------#

Once the GitHub repository and OIDC configuration are complete, deployment becomes automated.

Make a change to the application.

For example:

frontend/src/App.js

Then:
```
git add .
git commit -m "Update frontend"
git push origin main
```

GitHub Actions automatically starts the deployment workflow.

Monitor the workflow under:
```
GitHub
→ Actions
→ Deploy Student Management System
```
A successful run should show all steps passing.

#-------------------------CloudFront Deployment Verification----------------------------#

After the workflow completes successfully, open the CloudFront URL:

https://<cloudfront-domain>

For example:

https://d2v83xiaewg4q6.cloudfront.net

Perform a hard refresh if necessary:

Ctrl + Shift + R

The updated frontend should be displayed.

This confirms that:
```
Git Push
    ↓
GitHub Actions
    ↓
React Build
    ↓
S3
    ↓
CloudFront
    ↓
Updated Application
```
is working automatically.

#-------------------------------------Testing the Complete System------------------------------#

The final system should be tested from the browser.

Create

Create a new student and verify that the student appears in the table.

Read

Refresh the application and verify that the student remains present.

This confirms that the data was persisted in DynamoDB rather than only stored in frontend state.

Update

Edit an existing student and verify the updated values.

Delete

Delete the student and verify that it disappears from the table.

End-to-End Test

The complete request flow is:
```
User
 |
 v
CloudFront
 |
 v
React
 |
 | GET /students
 v
API Gateway
 |
 v
Get Student Lambda
 |
 v
DynamoDB
 |
 v
Student records
 |
 v
Lambda response
 |
 v
API Gateway
 |
 v
React
 |
 v
Student Table
```
This confirms the complete AWS serverless architecture is operational.

#----------------------------------Troubleshooting----------------------------#

Several issues were encountered during development.

1. Terraform Security Token Error
Error
The security token included in the request is invalid.

Terraform could not authenticate with AWS.

Cause

The local AWS CLI credentials were either missing, invalid, or not being picked up correctly.

The following command was used to inspect the AWS CLI configuration:

aws configure list

Environment variables were also checked.

On PowerShell:
```
Get-ChildItem Env:AWS*
```
Solution

The AWS CLI credentials were correctly configured using:

aws configure

The configuration was verified with:

aws sts get-caller-identity

After valid credentials were available, Terraform was able to execute:

terraform plan

successfully.

2. S3 Bucket Already Exists
Error

Terraform returned:
```
BucketAlreadyExists
The requested bucket name is not available.
The bucket namespace is shared by all users of the system.
Cause
```

S3 bucket names are globally unique across AWS.

A bucket name that looks available locally may already be owned by another AWS account.

Solution

Use a unique bucket name.

For example:

student-management-frontend-<unique-name>

or include a unique identifier.

After changing the bucket name:

terraform plan

and then:

terraform apply

3. CloudFront Returned 404 NoSuchKey
Error

CloudFront displayed:
```
404 Not Found


Code: NoSuchKey


Message: The specified key does not exist.


Key: index.html
```
Cause

CloudFront was trying to retrieve:

index.html

from S3, but the frontend build had not yet been uploaded to the bucket.

The infrastructure existed, but the application files were not yet deployed.

Solution

Build the React application:

npm run build

Then upload the build contents to S3:

aws s3 sync frontend/build/ s3://<bucket-name> --delete

After deployment, CloudFront could retrieve:

index.html

and the application became available.

The GitHub Actions pipeline later automated this process.

4. GitHub Actions OIDC AssumeRole Error
5. 
Error

GitHub Actions initially failed with:
```
Could not assume role with OIDC:
Not authorized to perform sts:AssumeRoleWithWebIdentity
```
Investigation

AWS CloudTrail was used to inspect the failed:

AssumeRoleWithWebIdentity

event.

The CloudTrail event showed:

eventName:
AssumeRoleWithWebIdentity

and:

errorCode:
AccessDenied

This confirmed that the problem was specifically related to the IAM role trust relationship rather than Terraform or the frontend.

Cause

The GitHub OIDC token was reaching AWS, but the IAM role trust policy was not authorizing that GitHub identity correctly.

Solution

The IAM role trust relationship was verified and configured to trust:

arn:aws:iam::<ACCOUNT_ID>:oidc-provider/token.actions.githubusercontent.com

The trust policy also verified:

aud = sts.amazonaws.com

and restricted the subject to the intended repository and main branch.

Once the trust relationship matched the GitHub Actions token, OIDC authentication succeeded.

5. npm ci Lockfile Error

Error

GitHub Actions initially failed during:

npm ci

with:
```
npm ci can only install packages when your package.json
and package-lock.json are in sync.
```

There was also an error indicating:

Missing: yaml@2.9.0 from lock file

Investigation

The same dependency problem was investigated locally.

The frontend contained:
```
package.json
package-lock.json
```

but the lockfile did not correctly represent the dependency tree required by the project.

Commands such as:

npm ls yaml

and:

npm explain yaml

were used to investigate the dependency tree.

Solution

The frontend dependencies were regenerated using npm.

The lockfile was updated and committed to Git.

The important point is that the CI pipeline continued using:

npm ci

rather than replacing it with:

npm install

because npm ci provides reproducible clean installations in CI environments.

6. Node.js Version Mismatch

Problem

The local environment was using:

Node.js v24.14.0

while the GitHub Actions workflow was initially configured to use a different Node.js version.

This contributed to inconsistencies between local development and the CI environment.

Solution

The GitHub Actions workflow was updated to use Node.js 24:
```
- name: Setup Node.js
  uses: actions/setup-node@v4
  with:
    node-version: 24
```

An important lesson was learned here:

Changes to the workflow file must be saved locally and committed before GitHub Actions can use them.

The workflow was saved, committed, and pushed to GitHub.

After that, the pipeline completed successfully.

7. Frontend Worked Locally but Went Blank on CloudFront

Problem

When the CloudFront URL was opened, the React application appeared briefly and then went blank.

Browser DevTools showed:

500 Internal Server Error

for the /students request.

It also showed:

TypeError: n.map is not a function

from StudentTable.js.

Investigation

The browser's developer console was used to identify the actual API request being made by the production frontend.

The browser was calling:

https://htjhdxy1f2.execute-api.us-east-1.amazonaws.com/dev/students

However, Postman testing showed that the working API endpoint was:

https://s0nebmmbzk.execute-api.us-east-1.amazonaws.com/dev/students

These were two different API Gateway APIs.

Cause

The frontend was configured with an outdated/wrong API Gateway URL.

The API itself was working correctly; the frontend was simply calling the wrong API.

Solution

The API URL in the frontend source code was changed to the correct API Gateway endpoint:

https://s0nebmmbzk.execute-api.us-east-1.amazonaws.com/dev

The change was committed and pushed:
```
git add .
git commit -m "Fix frontend API endpoint"
git push origin main
```

GitHub Actions rebuilt and redeployed the frontend.

After CloudFront was invalidated, the application worked correctly.

8. React .map() Error

Error

The browser displayed:
```
TypeError: n.map is not a function
```
Cause

The frontend expected the API to return an array of students.

However, the API request was returning an HTTP 500 error.

Therefore, the frontend was attempting to call:

students.map(...)

on a value that was not an array.

Root Cause

The .map() error was a secondary error.

The actual root cause was the incorrect API Gateway URL.

Solution

The API endpoint was corrected.

Once the frontend received the expected student array, the .map() error disappeared.

#------------------Security Considerations------------------#

Several security practices were implemented.

GitHub OIDC

GitHub Actions does not require long-lived AWS access keys.

Instead:
```
GitHub Actions
      |
      v
OIDC Token
      |
      v
AWS STS
      |
      v
IAM Role
```

This reduces the need to store permanent AWS credentials in GitHub.

IAM Role

GitHub Actions assumes an IAM role instead of using a permanent IAM user's access key.

The role should follow least-privilege principles.

Terraform State

Do not commit:
```
terraform.tfstate
terraform.tfstate.backup
```

to GitHub.

Secrets

Never commit:
```
AWS_ACCESS_KEY_ID
AWS_SECRET_ACCESS_KEY
AWS_SESSION_TOKEN
```

or other credentials to the repository.

#-----------------Important Files-----------------#
.github/workflows/deploy.yml

Contains the GitHub Actions CI/CD pipeline.

Responsible for:
---
- AWS authentication
- Terraform deployment
- Frontend dependency installation
- Frontend build
- S3 deployment
- CloudFront invalidation
---

terraform/

Contains Infrastructure as Code.

Responsible for defining AWS infrastructure.

Important files include:
```
providers.tf
variables.tf
outputs.tf
main.tf
iam.tf
lambda.tf
api_gateway.tf
frontend.tf
```

frontend/package.json

Defines frontend dependencies and scripts.

Important scripts include:
```
npm start
npm run build
```

frontend/package-lock.json

Locks dependency versions to provide reproducible installations.

It must be kept synchronized with:

package.json

so that:

npm ci

works correctly in GitHub Actions.

#-----------------------Recreating the Project-------------------------------#

The following sequence can be used to recreate the project.

Step 1 — Clone the Repository

git clone <repository-url>

cd student-management-aws-devops

Step 2 — Configure AWS CLI

aws configure

Provide valid AWS credentials and:

Region:
us-east-1

Verify:

aws sts get-caller-identity

Step 3 — Initialize Terraform

cd terraform

terraform init

Step 4 — Validate Terraform

terraform validate

Step 5 — Review Infrastructure

terraform plan

Step 6 — Deploy Infrastructure

terraform apply

Confirm with:

yes

Step 7 — Deploy/Test Backend

Deploy the Lambda functions and configure:

TABLE_NAME

Test all API endpoints using Postman.

Verify that data is correctly stored in DynamoDB.

Step 8 — Configure Frontend

Navigate to:

cd ../frontend

Install dependencies:

npm install

Build:

npm run build

Step 9 — Configure GitHub OIDC

Create the GitHub OIDC provider in AWS.

Use:

https://token.actions.githubusercontent.com

with audience:

sts.amazonaws.com

Create the GitHub Actions IAM role and configure the trust relationship.

Step 10 — Configure GitHub Repository Variable

Create:

AWS_ROLE_ARN

under:
```
Settings
→ Secrets and variables
→ Actions
→ Variables
```

Set its value to the IAM role ARN.

Step 11 — Push to GitHub
```
git add .
git commit -m "Initial CI/CD deployment"
git push origin main
```

GitHub Actions should automatically start.

Step 12 — Verify Deployment

Open:
```
GitHub
→ Actions
```
Confirm the deployment workflow succeeds.

Then open the CloudFront URL.

Test:
---
- Create student
- Read students
- Update student
- Delete student
---

#--------------------------CI/CD Verification Test------------------------#


The most important test of the project is to modify the frontend.

For example:

<h1>Student Management System v2</h1>

Commit the change:
```
git add .
git commit -m "Test automated deployment"
git push origin main
```
GitHub Actions should automatically:
```
Build
   ↓
Deploy
   ↓
Invalidate CloudFront
```
After the workflow succeeds, refresh the CloudFront URL.

If the new title appears, the CI/CD pipeline has been successfully verified.

#-------------------------Lessons Learned--------------------------------#

1. Infrastructure and application deployment are different things

Terraform can create the S3 bucket and CloudFront distribution, but that does not automatically mean the React application files are inside the S3 bucket.

The infrastructure must exist first, and the application must then be deployed.

2. S3 bucket names are globally unique

A bucket name cannot simply be reused because it exists in a different AWS account.

Unique naming is required.

3. OIDC is different from IAM access keys

GitHub Actions can authenticate to AWS without storing long-lived AWS credentials.

OIDC allows GitHub to obtain temporary AWS credentials by assuming an IAM role.

4. CloudTrail is useful for IAM troubleshooting

When GitHub Actions failed to assume the IAM role, CloudTrail provided much more useful information than the GitHub error alone.

The event:

AssumeRoleWithWebIdentity

confirmed that GitHub was reaching AWS but was being denied by IAM.

5. npm ci is stricter than npm install

A project may work with:

npm install

but fail with:

npm ci

if:

package.json

and:

package-lock.json

are not synchronized.

CI environments should generally use npm ci for reproducible builds.

6. Always verify the actual API endpoint

The frontend initially pointed to a different API Gateway URL than the one tested with Postman.

This demonstrated an important deployment lesson:

A backend can be completely healthy while the frontend is broken simply because it is configured to call the wrong API endpoint.

7. Browser DevTools are essential for frontend/cloud debugging

The blank CloudFront page initially looked like a CloudFront problem.

The browser console revealed:

500 Internal Server Error

and:

TypeError: n.map is not a function

This quickly narrowed down the problem.

8. Save and commit workflow changes

Changing:

deploy.yml

locally is not enough.

GitHub Actions only executes the version committed and pushed to GitHub.

#------------------------Final Architecture------------------------------#

The completed project demonstrates a complete cloud-native deployment pipeline:

```
                         +----------------+
                         |     GitHub     |
                         +-------+--------+
                                 |
                              git push
                                 |
                                 v
                     +-----------------------+
                     |    GitHub Actions     |
                     +-----------+-----------+
                                 |
                              OIDC
                                 |
                                 v
                     +-----------------------+
                     |       AWS IAM         |
                     |     OIDC Role         |
                     +-----------+-----------+
                                 |
                    +------------+------------+
                    |                         |
                    v                         v
              +-----------+            +-------------+
              | Terraform |            | React Build |
              +-----+-----+            +------+------+
                    |                         |
                    v                         v
             AWS Infrastructure             S3
                    |                         |
                    |                         v
                    |                    CloudFront
                    |                         |
                    |                         v
                    |                      Browser
                    |
                    v
              API Gateway
                    |
                    v
                 Lambda
                    |
                    v
               DynamoDB
```

#-----------------------------------Final Outcome----------------------------------------#

The Student Management System successfully demonstrates:

- Serverless AWS architecture
- REST API development
- Lambda-based backend services
- DynamoDB persistence
- React frontend development
- S3 static frontend hosting
- CloudFront content distribution
- Terraform Infrastructure as Code
- GitHub Actions CI/CD
- GitHub OIDC authentication
- IAM role-based AWS access
- Automated frontend deployment
- Automated CloudFront cache invalidation
- End-to-end CRUD functionality

The final deployment process requires only:
```
git add .
git commit -m "Update application"
git push origin main
```
After the push, GitHub Actions handles the deployment automatically.

Future Improvements

Possible improvements for future versions include:

- Add a Terraform remote backend using S3
- Add DynamoDB point-in-time recovery
- Add API authentication/authorization
- Add Amazon Cognito
- Add API Gateway custom domain
- Add HTTPS custom domain with Route 53 and ACM
- Add CloudWatch dashboards
- Add CloudWatch alarms
- Add structured Lambda logging
- Add automated backend unit tests
- Add frontend tests
- Add Terraform security scanning
- Add linting to GitHub Actions
- Add separate development and production environments
- Add pull-request validation before merging
- Add deployment approvals
- Implement blue/green or staged deployments
- Add vulnerability scanning
- Implement least-privilege IAM policies
- Move Terraform state to an S3 remote backend with state locking

#---------------------------Project Status----------------------------#

Status: Completed

The application has been successfully deployed to AWS and the CI/CD pipeline has been verified.

The final workflow allows application changes pushed to the main branch to be automatically built and deployed to the AWS environment.
