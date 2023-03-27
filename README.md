<a name="DataFlowDiagram"></a>

This 30-second video reveals each object and flow line in this busy diagram to summarize how all the major components interact with each other to build an enterprise environment:

[![Enterprise in Production using Terraform, Vault, Consul, Packer](https://res.cloudinary.com/dcajqrroq/image/upload/v1679893044/instant-hcp-vault-v02-1818x750_nyjd8o.jpg)](https://www.youtube.com/watch?v=Fx0XtgLUoJM "Enterprise in Production using Terraform, Vault, Consul, Packer")


## Multiple GitHub for Conway's Law

> This summarizes the technologies to create an <strong>anti-fragile</strong> enterprise production environment, quickly and securely.

Words in green font are the attributes of what is necessary to create an <strong>anti-fragile</strong> enterprise production environment.

Numbered bubbles on the flowchart mark the sequence of <strong>manual actions</strong>.

Resiliency often means having multiple options for each capability.

## Multi-cloud, Multi-region, Multi-az

Organizations, through acquisition or by design to meet customer demand for network resilience, find that they need to operate across several clouds to obtain the highest level of flexibility and resiliance.

Within each cloud, resiliance is achieved across <strong>several geographical Regions</strong> around the world, each several <strong>AZs</strong> (Availability Zones), in case one of them fails. 

## Web UI?

In typical enterprise production scenarios, <strong>multiple accounts</strong> are necessary to segregate permissions to dev vs. production <strong>environments</strong>, to reduce the "blast radius" when credentials for an account is stolen. 

PROTIP: All the different clouds, regions, accounts, environments makes it cumbersome to switch among browser <strong>web UI</strong> (browser User Interface) alone. And manual changes are not easily repeatable due to human error. In fact, some organizations have <strong>no web UI</strong> at all, and only allow use of versioned <strong>Infrastructure as Code (IaC)</strong> as the only way to create and manage infrastructure.

## Terraform HCL for IaC in Registry

HashiCorp created an open-sourced, free <strong>Terraform client</strong> program to automate the creation of resources based on definitions of versioned <strong>Infrastructure as Code</strong> in <strong>Terraform HCL</strong> (HashiCorp Configuration Language). Custom HCL are saved in version-controlled repositories within <strong>GitHub.com</strong>, GitLab, Bitbucket, or Azure DevOps. 

<em>NOTE: Boxes in brown are libraries that provide files that are referenced by the custom code in the blue boxes.</em>

HashiCorp has worked with each cloud infrastructure vendor to create Terraform <strong>providers</strong> that HashiCorp's Terraform program uses when it turns <strong>Terraform HCL</strong> code within <strong>.tf files</strong> into API calls that create resources. 

References from within custom Terraform HCL code to provider logic is provided from <a target="_blank" href="https://registry.hashicorp.io">https://registry.hashicorp.io</a>.


## Modules for cloud services

Each cloud vendor offers their own <strong>cloud service</strong> for networking (VPC), compute (EC2), storage (S3), databases (RDS), etc. The logic for each cloud service is stored in a <strong>module</strong> in <a target="_blank" href="https://registry.terraform.io/browse/modules">registry.terraform.io</a>.

Code <strong>templates</strong> and the <strong>resources</strong> they reference are also stored in the registry.

This public modularity enables repeatability and basic collaboration. 

## Multi-platform

Terraform for each cloud vendor is similar but not identical among clouds. But Terraform client operation is the same across all clouds, which is one reason for its popularity.

Sample Terraform repos makes it easy and quick to create <strong>Highly Available (HA) services</strong> in clusters within several clouds:
 
   * EKS (Elastic Kubernetes Service) in AWS
   * AKS (Azure Kubernetes Service)
   * GKE (Google Kubernetes Engine)
   <br /><br />

Defaults in standard configuration code enable runs of a full set enterprise features without much manual editing. The resources created can then be used as demos or customized for specific use cases.

## Multi-node as variables

The number of nodes within each Kubernetes cluster can be changed by <strong>overriding default values to variables</strong> in modules controlling what features and services you would like to deploy. 
The overrides can occur by editing <tt>main.tf</tt>. Some HCL repositories ask engineers to override main.tf with a <tt>auto.tfvars</tt> file, renamed.

## Helm Charts

Within each cloud Kubernetes service, some prefer to define Kubernetes add-ons using <strong>Helm Charts</strong>, the default package manager for Kubernetes.

There is a long list of add-ons available in the Kubernetes <a target="_blank" href="https://artifacthub.io/">https://artifacthub.io/</a>. Popular examples are open-source Prometheus to gather logs and statistics into its database, and Grafana to visualize what was collected.
There are often several add-ons for common functionality, such as <strong>cert-manager</strong> to automate the creation of TLS certificates for HTTPS, and <strong>external-dns</strong> to automate the creation of DNS records for services.


## Multi-OS (operating system)

Kubernetes was designed to operate on several operating systems. Linux is the most popular choice. But it can also run on Windows and macOS. The specific operating system used is set when the <strong>container</strong> is built (using Packer), and stored for access within <strong>Artifactory</strong> or other container registry. 

The Terraform client is written in Go, so can be run on Windows, macOS, or Linux without additional install (such as needed with Java, Python, C, etc.).

The number of replicas can be changed by overriding default values to variables in modules controlling what features and services you would like to deploy. 

## Multi-replicas

HashiCorp designed its application services <strong>Vault</strong> and <strong>Consul</strong> with modern sophisticated mechanisms to be not just highly available (HA) within a <strong>cluster</strong> of Kubernetes nodes. HashiCorp's app can be configured for large capacity by use of read-only replicas across regions.

Additionally, sophisticated mechanisms within <strong>HashiCorp's Vault and Consul</strong> enable them to serve high loads through <strong>replicas</strong> deployed across multiple AZs in multiple Regions around the world.

<strong>UI apps</strong> (such as Hashicups or the counting service) can be deployed with a database within Kubernetes or outside of Kubernetes. Either way, the app can reference Vault to obtain from the database a new dynamic database credential for each new connection. This is a common pattern for eliminating static long-term credentials that can be stolen.

   Sample applications with a UI (such as HashiCups) can be used to show how to replace static (unsecure long-term) passwords with dynamically created ones for use during a short window of time. We show how to arrange for PostgreSQL database to create temporary database credentials for distribution using HashiCorp's unique "AppRole" authentication method from a Vault one-time access Cubbyhole.

When the app is deployed outside of Kubernetes, HashiCorp Consul can ensure that communications be encrypted (using mTLS protocol). Consul also provides a service mesh to ensure that the app can discover the database and communicate with it.


## External utilities

Also due to organizational divisions and to limit "cognitive load" on individuals,
these common utility systems are usually established by separate groups using separate repositories:

* An <strong>Archival</strong> solution to backup and restore data
* A <strong>SIEM</strong> (Security Information and Event Management) solution such as Splunk, LogRhythm, <a target="_blank" href="https://www.datadoghq.com/dg/security/siem-solution/">Datadog</a>, <a target="_blank" href="https://www.comparitech.com/net-admin/siem-tools/">etc.</a> which retrieves, ingests, aggregates, and correlates variouos <strong>logs</strong> from various services into analytic dashboards
* An <strong>Alerting</strong> solution which evaluates data within SIEM to issue alerts, with escalations when alerts are not acknowledged in a timely manner.
<br /><br />

In many enterprises, a <strong>corporate-wide central</strong> <a target="_blank" href="https://www.checkpoint.com/cyber-hub/threat-prevention/what-is-soc/">SOC (Security Operations Center)</a> uses their SIEM 24/7/365 to monitor, triage, and respond to cyber threats.

## Corporate IdP and Vault

Due to the principle of "segregation of duties", large organizations have a separate team manage the corporate IdP (Identity Provider) system to authenticate users to access the corporate network and applications. Such systems provide MFA (MultiFactor Authentication) mechanisms to make users prove control of their data.

A corporate Vault system is often used to store and manage the credentials for the IdP system. This is a common pattern for eliminating static long-term credentials that can be stolen.

   When the person initiating runs authenticates with Okta, their script would be able to establish cloud credentials needed to authenticate runs.


## Individual DevOps laptops

The Terraform client runs in several contexts. 

<strong>DevOps/Platform Engineers</strong> can run the Terraform client on their laptops.

3. They install the Terraform client and pre-requisite utilities by <a href="#Install">running a shell script</a> (on a macOS laptop).

   On a macOS, the script installs <strong>Homebrew</strong> and other package managers for easier upgrade. If pre-requisites for brew isn't installed, the script would install them.

   The script installs GitHub's <tt>gh</tt> utility to fork the custom Terraform HCL from github.com before downloading it.

   BTW the most popular editor is Microsoft's Visual Studio Code (VSCode) which is free and open source.


   ### Continuous Integration & Testing

4. Most enterprises now run a series of <strong>tasks after each change</strong>.

   Trivey, tfsec, Checkov <a href="#ScanTF">identify vulnerabilities in Terraform HCL code</a> so that vulnerabilities in cloud resources can be elminated even <strong>before they are created</strong>. Once created, your resources can be hacked immediately.

   HashiCorp has limited some <strong>Sentinel</strong> policy functionality to only licensed users.
   It confirms that policies-as-code are not violated.

   There are several ways to <a href="#DeployTF">run terraform</a> to create cloud resources. 

   ### Local tfstate files

   <tt>terraform plan</tt> and <tt>terraform apply</tt> commands are used on a stand-alone laptop to create cloud resources.

   When Terraform client runs locally, it creates for itself a <strong>local tfstate file</strong> to remember what it created.
   
   Some users of open-source Terraform configure a <strong>backend.tf</strong> file to specify a remote location, such as a <strong>S3</strong> bucket or DynamoDB.   

   ### TFC (Terraform Cloud)

5. Even more useful is HashiCorp's <strong>TFC (Terraform Cloud)</strong>, which provides features in addition to a place to store versioned state files. It's free but extra features can be licensed.

   <a href="#SetTFCEnv">Setup TFC</a> environment variables to connect to TFC.

   <a href="#WhyHCP">Why use Terraform Cloud?</a>

   DevOps engineers don't need a laptop if they use TFC SaaS (Software as a Service). TFC provides a <strong>web UI</strong>reachable on internet web browsers. Runs can be initiated using the HCP (HarshiCorp Platform) GUI, which enables Custom HCP Sentinel or OPA rules can be defined (such as to ensure that tags have been defined in all HCL for accurate project billing).

   Like other SaaS (Software as a Service), HashiCorp frees you from managing the underlying multi-region/multi-AZ HA infrastructure, and provides hosting of Terraform state and lock files.

   TFC is described using the acroymn "TACOS" (Terraform Automation & Collaboration Software) because it enables <strong>scaling</strong> across many teams. It provides administrators to track utilization over time. 
   
   The web UI standardizes permissions and workflows across teams.

   The automation can optionally include automatic generation of diagrams from HCL or resource created in the cloud.

6. HCP can run Terraform restricted on each workspace.

7. Define automated workflow tasks such as HashiCorp Sentinel to enforce policies and processing such as <strong>Synk</strong> to scan containers. 

8. To use Vault HCP, create a HCP account to obtain a HCP Organization name. You then <a href="#SetHCPEnv">Setup HCP environment variables</a> to connect to TFC. 

   HCP creates and uses a HVN to access cloud infrastructure.

   Each team is provided a separate <strong>Workspaces</strong> to segregate work among different teams. 

   Custom HCL is loaded onto HCP from github.com.


   Output from runs include the Vault service URL and credential token.

9.  Use the cloud console GUI to <a href="#ConfirmHCP">Confirm HCP</a> and <a href="#ConfirmAWSGUI">Confirm resources in AWS GUI</a>.

   WARNING: Do not make changes using the cloud GUI, which creates <strong>drift</strong> from configurations defined.
   
   Install on application <strong>developer's</strong> laptops CLI (Command Line Interface), SSH (Secure Shell), and other utilities that include a Vault client to cache secrets. A local Jupyter server program with Docker can be installed for use in demonstrating commands exercising Vault and Consul.   

10. <a href="#AccessVaultCLI">CLI commands can obtain from within Kubernetes the <a href="#AccessVaultURL">URL and credentials to Vault</a> and Consul.

    <a href="#ConfigSecretsEngines">Configure Secrets Engines</a> such that Vault can <strong>cache secrets</strong>  so applications can access secrets without wearing out the Vault server.
    
    * <a href="#VaultMenu">View the Vault Admin menu</a> UI. 
    * <a href="#AccessVaultCLI">Access Vault using CLI</a>
    * <a href="#AccessVaultAPI">Access Vault API programming</a>

    * <a href="#ConfigSecretsEngines">Configure Secrets Engines</a>.

    * <a href="#VaultTools">Use Vault Tools</a>.

    Commands can be run to obtain Application URLs and database URLs.

    Consul can be used to <strong>discover</strong> services running in Kubernetes.

11. Ensure there is adequate backup capability by testing procedures to restore from archives. This is also a good time to measure MTTR and practice Incident Management.

    PROTIP: When resources can be recreated quickly, there is less fear of destroying <a href="#DestroyVault">Vault</a> and other resources, resulting in less idle resources consuming money for no good reason. 

12. To provide visibility to the <strong>security posture</strong> of your system, filter logs gathered and view structure analytics displayed using Grafana installed using auxilliary scripts.

    If a SIEM (such as Splunk or Datadog) is available, view alerts generated from logs sent to them.

13. Populate enough fake/test users with credentials obtained from your IdP (Identity Provider) <a href="#CreateUsers">Creating User Accounts</a>, <a href="#ConfigPolicies">Configuring Policies</a>, and <a href="#EditPolicies">Editng Policies</a>. This is done by coding API in app programs.

    PROTIP: Identify users and teams in production and invite/load them in the system (via IdP) early during the implementation project for less friction before users can begin work with minimal effort.

14. Create and run (perhaps run overnight) <strong>test flows</strong> (coded in Jupyter or K6 JavaScript) to verify functional, performance, and capacity to emulate activity from end-user clients. This enables monitoring over time of latency between server and end-users, which can impair user productivity.

    TODO: GitHub Actions workflows are included here to have a working example of how to retrieve secrets from Vault, such as <a href="#GitHubOIDC">GitHub OIDC</a> protocol.

15. Verify configuration on every change. This is important to really determine whether the whole system works both before and after <a href="#Upgrade">changing/upgrading any component</a> (Versions of Kubernetes, operating system, Vault, etc.). The Enterprise version of Terraform, Vault, and Consul provide for automation of upgrades.

    Again, use of Infrastructure-as-Code enables quicker response to security changes identified over time, such as for EC2 IMDSv2.    

16. Migrate?

17. Upgrade? the Enterprise and Cloud editions provide for automation of upgrades.

<br /><br />

## Recap:

<a target="_blank" href="https://res.cloudinary.com/dcajqrroq/image/upload/v1679893044/instant-hcp-vault-v02-1818x750_nyjd8o.jpg"><img alt="instant-hcp-vault-v02-1818x750.jpg"  src="https://res.cloudinary.com/dcajqrroq/image/upload/v1679893044/instant-hcp-vault-v02-1818x750_nyjd8o.jpg"></a>

<em>The following provides more details on the manual steps summarized above.</em>

<hr />

<a name="WhyHCP"></a>

### Why HCP SaaS? #

There are several ways to create a HashiCorp Vault instance.

The approach as described in this tutorial has the following advantages:

1.  Solve the "Secret Zero" problem: use using HashiCorp's MFA (Multi-Factor Authentication) embedded within HCP (HashiCorp Cloud Platform) secure infrastructure to authenticate Administrators, who have elevated privileges over all other users.

2.  Ease of use: Use of the HCP GUI means no complicated commands to remember, especially to perform emergency "break glass" procedures to stop Vault operation in case of an intrusion. 

3.  HCP provides <strong>separate workflows</strong> so that potential impact from loss of credentials (through phising and other means) result in a smaller "blast radius" exposure.


<hr />

<a name="Why"></a>

### Why HCP? #

There are several ways to create a HashiCorp Vault or Consul instance (cluster of nodes within Kubernetes).

The approach as described in this tutorial has the following advantages:

1.  Solves the "Secret Zero" problem: use using HashiCorp's MFA (Multi-Factor Authentication) embedded within HCP (HashiCorp Cloud Platform) secure infrastructure to authenticate Administrators, who have elevated privileges over all other users.

2.  Use <strong>pre-defined</strong> Terraform <strong>modules</strong> which have been reviewed by several experienced professionals to contain secure defaults and mechanisms for <a target="_blank" href="https://developer.hashicorp.com/vault/tutorials/operations/production-hardening">security hardening</a> that include:

    * RBAC settings by <strong>persona</strong> for Least-privilege permissions (separate accounts to read but not delete)

    * Verification and automated implementation of the latest TLS certificate version and Customer-provided keys
    * End-to-End encryption to protect communications, logs, and all data at rest
    * Automatic dropping of invalid headers
    * Logging enabled for audit and forwarding
    * Automatic movement of logs to a SIEM (such as Splunk) for analytics and alerting
    * Automatic purging of logs to conserve disk space usage
    * Purge protection (waiting periods) on KMS keys and Volumes

    * Enabled automatic secrets rotation, auto-repair, auto-upgrade
    * Disabled operating system swap to prevent the from paging sensitive data to disk. This is especially important when using the integrated storage backend.
    * Disable operating system core dumps which may contain sensitive information
    * etc.
    <br /><br />

3.  Use of Infrastructure-as-Code enables quicker response to security changes identified over time, such as for EC2 IMDSv2.

4.  Ease of use: Use of the HCP GUI means no complicated commands to remember, especially to perform emergency "break glass" procedures to stop Vault operation in case of an intrusion. 

5.  Use of "feature flags" to optionally include Kubernetes add-ons needed for production-quality use:

    * DNS
    * Verification of endpoints
    * Observability Extraction (Prometheus)
    * Analytics (dashboarding) of metrics (Grafana)
    * Scaling (Kubernetes Operator <a target="_blank" href="https://karpenter.sh/">Karpenter</a> or cluster-autocaler) to provision Kubernetes nodes of the right size for your workloads and remove them when no longer needed
    * Troubleshooting
    * etc.
    <br /><br />

6.  TODO: Use of a CI/CD pipeline to version every change, automated scanning of Terraform for vulnerabilities (using TFSec and other utilities), and confirmation that policies-as-code are not violated.


<a name="Install"></a>

### &nbsp; &nbsp; &nbsp; &#9744; Install utility programs

1.  If you are using a MacOS machine, install Apple's utilities, then Homebrew formulas:

    <pre><strong>xcode select --install
    brew install  git  jq  awscli  tfsec  vault  kubectl
    </strong></pre>

    NOTE: HashiCorp Enterprise users instead use the Vault enterprise (<tt>vault-ent</tt>) program.


    <a name="SetAWSEnv"></a>

    ### &#9744; Set AWS environment variables:

24. In the Terminal window you will use to run Terraform in the next step, set the AWS account credentials used to build your Vault instance, such as:
    ```bash
    export AWS_ACCESS_KEY_ID=ZXYRQPONMLKJIHGFEDCBA
    export AWS_SECRET_ACCESS_KEY=abcdef12341uLY5oZCi5ILlWqyY++QpWEYnxz62w
    ```
    
    <a name="SetHCPEnv"></a>

    ### &#9744; Set cloud environment variables

    Below are steps to obtain credentials used to set up HCP within AWS:
    ```bash
    export HCP_CLIENT_ID=1234oTzq81L6DxXmQrrfkTl9lv9tYKHJ
    export HCP_CLIENT_SECRET=abcdef123mPwF7VIOuHDdthq42V0fUQBLbq-ZxadCMT5WaJW925bbXN9UJ9zBut9
    ```
    Most enterprises allocate AWS dynamically for a brief time (such as HashiCorp employees using "Bootcamp"). So the above are defined on a Terminal session for one-time use instead of being stored (long term, statically) in a <tt>$HOME/.zshrc</tt> or <tt>$HOME/.bash_profile</tt> file run automatically when a Terminal window is created.

    <a name="SignInHCP"></a>
    ### &#9744; Set HCP environment variables    
2.  Be at the browser window which you want a new tab added to contain the URL in the next step:
3.  Click this URL to open the HCP portal:
    
    <a target="_blank" href="https://portal.cloud.hashicorp.com/">https://portal.cloud.hashicorp.com</a>

4.  Click "Sign in" or, if you haven't already, "Create an account" (for an "org" to work with) to reach the Dashboard for your organization listed at the bottom-left.

5.  PROTIP: To quickly reach the URL specific to your org, save it to your bookmarks in your browser.
6.  REMEMBER: HCP has a 7-minute interaction timeout. So many users auto-populate the browser form using 1Password, which stores and retrieves credentials locally.
   
7.  Click "Access control (IAM)" on the left menu item under your org. name.
8.  Click "Service principals" (which act like users on behalf of a service).
9.  Click the blue "Create Service principal".
10. Specify a Name (for example, JohnDoe-23-12-31) for a Contributor.

    PROTIP: Add a date (such as 23-12-31) to make it easier to identify when it's time to refresh credentials.

11. Click "Save" for the creation toast at the lower left. 
12. Click "Generate key" at the right or "Create service principal key" in the middle of the screen.

13. Click the icon for the <strong>Client ID</strong> to copy it into your Clipboard.
14. Switch to your Terminal to type, then paste from Clipboard a command such as:
    ```bash
    export HCP_CLIENT_ID=1234oTzq81L6DxXmQrrfkTl9lv9tYKHJ
    ```
15. Switch back to HCP.
16. Click the icon for the <strong>Client secret</strong> to copy it into your Clipboard.
17. Switch to your Terminal to type, then paste from Clipboard a command such as:
    ```bash
    export HCP_CLIENT_SECRET=abcdef123mPwF7VIOuHDdthq42V0fUQBLbq-ZxadCMT5WaJW925bbXN9UJ9zBut9
    ```

    <a name="SelectExample"></a>
    
    ### &#9744; Select Example Deploy in Repo
 
18. Obtain a copy of the repository onto your laptop:
    ```bash
    git clone git@github.com:stoffee/csp-k8s-hcp.git
    cd csp-k8s-hcp
    ```
19. Since the <tt>main</tt> branch of this repo is under active change and thus may be unstable, copy to your Clipboard the last stable release of this repo to use at:

    <a target="_blank" href="https://github.com/stoffee/csp-k8s-hcp/releases">
    https://github.com/stoffee/csp-k8s-hcp/releases</a>

20. Identify release tag (such as "v0.0.6").
21. Click "Code" on the menu bar, then the green "Code" to obtain the SSH clone name:
22. In a Terminal, navigate to a folder where you will be cloning the repo
23. Clone the repo and checkout the release/version in the previous step:
    ```bash
    git clone git@github.com:stoffee/csp-k8s-hcp.git
    cd csp-k8s-hcp
    git checkout v0.0.6
    ```
    Alternately, you can Fork on the GUI, then clone using your own instead of the "stoffee" account.

    Notice that the repo is structured according to the HashiCorp recommended structure of folders and files at<br />https://developer.hashicorp.com/terraform/language/modules/develop/structure

24. Navigate into one of the <a target="_blank" href=https://github.com/stoffee/csp-k8s-hcp/tree/primary/examples>example</a> folder of deployments:
    ```bash
    cd examples
    cd full-deploy
    ```
    NOTE: <tt><strong>full-deploy</strong></tt> example assumes the use of a "Development" tier of Vault instance size, which incur charges as described at
    <a target="_blank" href="https://cloud.hashicorp.com/products/vault/pricing">https://cloud.hashicorp.com/products/vault/pricing</a>.
    
    Alternately, the <tt><strong>eks-hvn-only-deploy</strong></tt> example only creates the HVN (HashiCorp Virtual Network). <a target="_blank" href="https://developer.hashicorp.com/hcp/docs/hcp/network">DEFINITION</a>: An HVN delegates an IPv4 CIDR range that HCP uses to automatically create resources in a cloud region. The HCP platform uses this CIDR range to automatically create a virtual private cloud (VPC) on AWS or a virtual network (VNet) on Azure.

    <a name="ProductionDeploy"></a>
    
    ### &#9744; TODO: Production Deploy?

    TODO: Example <tt><strong>prod-eks</strong></tt> (production-high availability) constructs (at a higher cost) features not in dev deploys:
    * Larger "Standard" type of servers
    * Vault clusters in each of the three Availability Zones within a single region
    * RBAC with least-privilege permissions (no wildcard resource specifications)
    * Encrypted communications, logging, and data at rest
    * Emitting VPC, CloudWatch, and other logs to a central repository for auditing and analysis by a central SOC (Security Operations Center)
    * <a target="_blank" href="https://n2ws.com/blog/how-to-guides/automate-amazon-ec2-instance-backup">Instance Backups</a>
    * <a target="_blank" href="https://aws.amazon.com/premiumsupport/knowledge-center/deleteontermination-ebs/">AWS Volume Purge Protection</a>
    * Node pools have automatic repair and auto-upgrade
    <br /><br />

    TODO: Example <tt><strong>dr-eks</strong></tt> (disaster recovery in production) example repeats example <tt>prod-eks</tt> to construct (at a higher cost) enable fail-over recovery among <strong>two regions</strong>.
    
    TODO: <a target="_blank" href="https://developer.hashicorp.com/vault/docs/enterprise/replication">Replication</a> for high transaction load.


    <a name="Edit_tfvars"></a>

    ### &#9744; Edit options in sample.auto.tfvars

25. Rename <tt>sample.auto.tfvars_example</tt> to <tt>sample.auto.tfvars</tt>
    ```bash
    cp sample.auto.tfvars_example  sample.auto.tfvars
    ```
    NOTE: Your file <tt>sample.auto.tfvars</tt> is specified in the <a target="_blank" href="https://github.com/stoffee/csp-k8s-hcp/blob/main/.gitignore">this repo's .gitignore</a> file so it doesn't get uploaded into GitHub.

26. Use a text editor program (such as VSCode) to customize the <tt>sample.auto.tfvars</tt> file. For example:

    <pre>cluster_id = "dev1-eks"
    deploy_hvn = true
    hvn_id               = "dev-eks"
    hvn_region           = "us-west-2"
    vpc_region           = "us-west-2"
    deploy_vault_cluster = true
    # uncomment this if setting deploy_vault_cluster to false for an existing vault cluster
    #hcp_vault_cluster_id = "vault-mycompany-io"
    make_vault_public    = true
    deploy_eks_cluster   = true
    </pre>
    
    During deployment, Terraform HCL uses the value of <tt>cluster_id</tt> (such as "dev-blazer") to construct the value of <tt>eks_cluster_name</tt> ("dev-blazer-eks") and <tt>eks_cluster_arn</tt> ("dev-blazer-vps").

    CAUTION: Having a different hvn_region from <tt>vpc_region</tt> will result in expensive AWS cross-region data access fees and slower performance.

    TODO: Additional parmeters include: the number of nodes in Kubernetes (3 being the default).
    
    TODO: Several variables in your <tt>sample.auto.tfvars</tt> file overrides both the <a href="#GHAWorkflow">sample GitHub Actions workflow file</a> and the "claims" within "JWT tokens" sent to request secrets from Vault using OIDC (OpenID Connect) standards of interaction:
    * <tt>github_enterprise="mycompany"</tt> 
    * TODO: <tt>vault_role_oidc_1=github_oidc_1</tt>
    * TODO: <tt>env='prod'</tt> segregates access to secrets between jobs within <a target="_blank" href="https://docs.github.com/en/actions/deployment/targeting-different-environments/using-environments-for-deployment">GitHub Pro/Enterprise Environments</a> protected by rules and secrets. GitHub Environment protection rules require specific conditions to pass before a job referencing the environment can proceed. You can use environment protection rules to require a manual approval, delay a job, or restrict the environment to certain branches.
    * GITHUB_ACTOR
    * GITHUB_ACTION (name of action run)
    * GITHUB_JOB (job ID of current job)
    * GITHUB_REF (branch/tag that triggered workflow)
    <br /><br />
    
    TODO: This repo has pre-defined sample <strong>Vault roles and scopes (permissions)</strong> used to validate claims in JWT tokens received.
    Changing them would require editing of files before deployment.


    <a name="GHAWorkflow"></a>

    ## &#9744; GitHub Actions workflow

    From https://wilsonmar.github.io/github-actions
    GitHub added an "Actions" tab to repos (in 2019) to perform Continuous Integration (CI) like Jenkins.
    GitHub Action files are stored within the repo's <tt>.github</tt> folder.<br />
    The <tt>Workflows</tt> folder contain <strong>declarative yml</strong> files which define what needs to happen at each step.<br />
    The <tt>Scripts</tt> folder contain <strong>programmatic sh</strong> (Bash shell) files which perform actions.

    TODO: The sample workflow defined in this repo is set to be <strong>triggered</strong> to run when 
    a PR is merged into GitHub (rather than run manually).
    TODO: By default, within the repo's <tt>trigger-action</tt> folder is file <tt>changeme.txt</tt>
    
    References: Sample files related to GitHub Actions in this repo are based on several sources:
    * helper actions within https://github.com/hashicorp/vault-action 
    * https://github.com/artis3n/course-vault-github-oidc
    * https://github.com/ned1313/vault-oidc-github-actions/blob/main/.github/workflows/oidc_test.yml
    <br /><br />

    <a name="ScanTF"></a>

    ### &#9744; Scan Terraform for vulnerabilities

25. In the same Terminal window as the above step (or within a CI/CD workflow), run a static scan for security vulnerabilities in Terraform HCL:
    ```bash
    tfsec | sed -r "s/\x1B\[([0-9]{1,2}(;[0-9]{1,2})?)?[m|K]//g"
    ```
    NOTE: The sed command filters out most of the special characters output to display colors.

    WARNING: Do not continue until concerns raised by TFSec found are analyzed and remediated.


    <a name="DeployTF"></a>

    ### &#9744; Run Terraform to Deploy

26. In the same Terminal window as the above step (or within a CI/CD workflow), run the Terraform HCL to create the environment within AWS based on specifications in <tt>sample.auto.tfvars</tt>:
    ```bash
    terraform init
    terraform plan
    time terraform apply -auto-approve
    ```

    PROTIP: Those who work with Terraform frequently define aliases such as <tt>tfi</tt>, <tt>tfp</tt>, <tt>tfa</tt> to reduce keystrokes and avoid typos.

    If successful, you should see metadata output about the instance just created:
    <pre>cluster_security_group_arn = "arn:aws:ec2:us-west-2:123456789123:security-group/sg-081e335dd11b10860"
    cluster_security_group_id = "sg-081e335dd11b10860"
    eks_cluster_arn = "arn:aws:eks:us-west-2:123456789123:cluster/dev-blazer-eks"
    eks_cluster_certificate_authority_data = "...=="
    eks_cluster_endpoint = "https://1A2B3C4D5E6F4B5F9C8FC755105FAA00.gr7.us-west-2.eks.amazonaws.com"
    eks_cluster_name = "dev-blazer-eks"
    eks_cluster_oidc_issuer_url = "https://oidc.eks.us-west-2.amazonaws.com/id/1A2B3C4D5E6F4B5F9C8FC755105FAA00"
    eks_cluster_platform_version = "eks.15"
    eks_cluster_status = "ACTIVE"
    kubeconfig_filename = &LT;&LT;EOT
    /Users/wilsonmar/githubs/csp-k8s-hcp/examples/full-deploy/apiVersion: v1
    kind: ConfigMap
    metadata:
    name: aws-auth
    namespace: kube-system
    data:
    mapRoles: |
        - rolearn: arn:aws:iam::123456789123:role/node_group_01-eks-node-group-12340214203844029700000001
        username: system:node:{{EC2PrivateDNSName}}
        groups:
            - system:bootstrappers
            - system:nodes
    EOT
    node_security_group_arn = "arn:aws:ec2:us-west-2:123456789123:security-group/sg-abcdef123456789abc"
    node_security_group_id = "sg-abcdef123456789abc"
    vault_private_url = "https://hcp-vault-private-vault-9577a2dc.993dfd61.z1.hashicorp.cloud:8200"
    vault_public_url = "https://hcp-vault-public-vault-9577a2dc.993dfd61.z1.hashicorp.cloud:8200"
    vault_root_token = &LT;sensitive&LT;
    </pre>

    This sample time output shows 22 minutes 11 seconds total clock time:

    <pre>terraform apply -auto-approve  7.71s user 3.53s system 0% cpu 22:11.66 total</pre>

    One helpful design feature of Terraform HCL is that it's "declarative". So <tt>terraform apply</tt> can be run again. A sample response if no changes need to be made:
    ```bash
    No changes. Your infrastructure matches the configuration.
    Terraform has compared your real infrastructure against your configuration and found no differences, so no changes are needed.
    ```

    NOTE: Terraform verifies the status of resources in the cloud, but does not verify the correctness of API calls to each service.

    


    <a name="ConfirmHCP"></a>

    ### &#9744; Confirm HCP

    Switch back to the HCP screen to confirm what has been built:

27. In an internet browser, go to the <a href="https://portal.cloud.hashicorp.com/">HCP portal Dashboard at https://portal.cloud.hashicorp.com</a>
28. Click the blue "View Vault".
29. Click the Vault ID text -- the text above "Running" for the <strong>Overview</strong> page for your Vault instance managed by HCP. The <strong>Cluster Details</strong> page should appear, such as this:

    <a target="_blank" href="https://res.cloudinary.com/dcajqrroq/image/upload/v1676446677/hcp-vault-dev-320x475_gh8olg.jpg"><img src="https://res.cloudinary.com/dcajqrroq/image/upload/v1676446677/hcp-vault-dev-320x475_gh8olg.jpg"></a>
    
    Notice that the instance created is an instance that's "Extra Small", with No HA (High Availability) of clusters duplicated across several Availability Zones.

    CAUTION: You should not rely on a <strong>Development</strong> instance for productive use. Data in Development instances are forever lost when the server is stopped.

30. PROTIP: For quicker access in the future, save the URL in your browser bookmarks.

    <a name="ConfirmAWSGUI"></a>

    ### &#9744; Confirm resources in AWS GUI

31. Use the AWS Account, User Name, and Password associated with the <a href="#SetAWSEnv">AWS variables</a> mentioned above to view different services in the AWS Management Console GUI <a target="_blank" href="https://us-east-1.console.aws.amazon.com/cost-management/home?region=us-east-1#/dashboard">AWS Cost Explorer</a>:

    1. <a target="_blank" href="https://console.aws.amazon.com/eks/">Elastic Kubernetes Service</a> Node Groups (generated), EKS cluster
    2. <a target="_blank" href="https://console.aws.amazon.com/vpc/">VPC</a> (Virtual Private Cloud) Peering connections, NAT Gateways, Network interfaces, Subnets, Internet Gateways, Route Tables,  Network ACLs, Peering, etc.
    3. <a target="_blank" href="https://console.aws.amazon.com/ec2/">EC2</a> with Elastic IPs, Instances, Elastic IPs, Node Groups, Volumes, Launch Templates, Security Groups
    4. <a target="_blank" href="https://console.aws.amazon.com/ebs/">EBS</a> (Elastic Block Store) volumes
    5. <a target="_blank" href="https://console.aws.amazon.com/kms/">KMS</a> (Key Management Service) Aliases, Customer Managed Keys
    6. <a target="_blank" href="https://console.aws.amazon.com/cloudwatch/">CloudWatch</a> Log groups
    7. <a target="_blank" href="https://console.aws.amazon.com/guardduty/">AWS Guard Duty</a> 
    <br /><br />

    NOTE: Vault in Development mode operates an <strong>in-memory</strong> database and so does not require an external database.

    <a target="_blank" href="https://www.youtube.com/watch?v=8BwDrzeHOks" title="Find and Delete all AWS Resources Using Cost Explorer & Tag Editor">VIDEO</a>
    
    CAUTION: Please resist changing resources using the AWS Management Console GUI, which breaks version controls and renders obsolete the state files created when the resources were provisioned.
    
32. Obtain a list of resources created:
    ```bash
    terraform state list
    ```

    <a name="AccessVaultURL"></a>

    ### &#9744; Obtain Vault GUI URL

33. Be at the browser window you will add a new tab for the Vault UI.
34. Switch to your Terminal to open a browser window presenting the HCP Vault cluster URL obtained (on a Mac) using this CLI command:

    ```bash
    open $(terraform output --raw vault_public_url)
    ```
    Alternately, if you're using a client within AWS:
    ```bash
    open $(terraform output --raw vault_private_url)
    ```
    Either way, you should see this form:

    <a target="_blank" href="https://res.cloudinary.com/dcajqrroq/image/upload/v1675396720/vault-hcp-signin-468x397_g5twps.jpg"><img width="400" src="https://res.cloudinary.com/dcajqrroq/image/upload/v1675396720/vault-hcp-signin-468x397_g5twps.jpg"></a>

    REMEMBER: The "administrator for login credentials" are automatically provided an <strong>/admin</strong> namespace within Vault.

    NOTE: The administrator informs users of Vault about what authorization methods are available for each user, and how to sign in using each authentication method.

    <a target="_blank" href="https://res.cloudinary.com/dcajqrroq/image/upload/v1676722172/vault-signin-auth-methods-118x227_n7ozq8.jpg"><img alt="vault-signin-auth-methods-118x227.jpg" width="118" height="227" src="https://res.cloudinary.com/dcajqrroq/image/upload/v1676722172/vault-signin-auth-methods-118x227_n7ozq8.jpg"></a>

35. PROTIP: Optionally, save the URL as a Bookmark in your browser for quicker access in the future.

36. Copy the admin Token into your Clipboard for "Sign in to Vault" (on a Mac). 
    ```bash
    terraform output --raw vault_root_token | pbcopy
    ```
    That is equivalent to clicking <strong>Generate token</strong>, then <strong>Copy</strong> (to Clipboard) under "New admin token" on your HCP Vault Overview page.

    CAUTION: Sharing sign in token with others is a violation of corporate policy. Create a separate account and credentials for each user.

37. Click <strong>Token</strong> selection under the "Method" heading within the "Sign in" form.

    NOTE: Generation of a temporary token is one of <a target="_blank" href="https://developer.hashicorp.com/vault/docs/auth">many Authentication Methods</a> supported by Vault.

    REMEMBER: The token is only good for (has a Time to Live of) <strong>6 hours</strong>.

38. Click in the <strong>Token</strong> field within the "Sign in" form, then paste the token.

39. Click the blue "Sign in" (as Administrator).


    <a name="VaultMenu"></a>

    ### &#9744; Vault Admin menu

    If Sign in is successful, you should see this Vault menu:

    <a target="_blank" href="https://res.cloudinary.com/dcajqrroq/image/upload/v1675399191/vault-hcp-main-menu-485x53_lhdolz.jpg"><img width="485" height="53" src="https://res.cloudinary.com/dcajqrroq/image/upload/v1675399191/vault-hcp-main-menu-485x53_lhdolz.jpg"></a>

    The first menu item, "Secrets" is presented by default upon menu entry:

    <a target="_blank" href="https://res.cloudinary.com/dcajqrroq/image/upload/v1676723576/vault-secrets-240x196_l3vjvi.jpg"><img alt="vault-secrets-240x196.jpg" width="240" height="196" src="https://res.cloudinary.com/dcajqrroq/image/upload/v1676723576/vault-secrets-240x196_l3vjvi.jpg"></a>

    TODO: Automation in this repo has already mounted/enabled several <a target="_blank" href="https://developer.hashicorp.com/vault/docs/secrets">Vault Secrets Engines</a> to generate different types of secrets:

    * <strong>kv/</strong> (Key/Value) stores secret values accessed by a key.
    https://developer.hashicorp.com/vault/tutorials/getting-started/getting-started-first-secret

    * <a target="_blank" href="https://developer.hashicorp.com/vault/docs/secrets/cubbyhole">>cubbyhole/</a> stores each secret so that it can be accessed only one time. (Transmission of such secrets make use of "wrapping" using "AppRole" which creates the equivalent of a username/password for use by computer services without a GUI)

40. Click "Access" on the <a href="#VaultMenu">menu</a> to manage mechanisms that Vault provides other systems to control access:

    <a target="_blank" href="https://res.cloudinary.com/dcajqrroq/image/upload/v1675424226/vault-hcp-access-menu-212x267_qkyci7.jpg"><img width="212" height="267" src="https://res.cloudinary.com/dcajqrroq/image/upload/v1675424226/vault-hcp-access-menu-212x267_qkyci7.jpg"></a>

    Tutorials and Documentation on each menu item:
    * <a target="_blank" href="https://developer.hashicorp.com/vault/docs/auth">Auth Methods</a> perform authentication, then assign identity and a set of policies to each user.
    * <a target="_blank" href="https://developer.hashicorp.com/hcp/docs/hcp/security/mfa">Multi-factor authentication</a> 
    * <a target="_blank" href="https://developer.hashicorp.com/vault/tutorials/auth-methods/identity">Entities</a> define <strong>aliases</strong> mapped to a common property among different accounts
    * <a target="_blank" href="https://developer.hashicorp.com/vault/tutorials/enterprise/control-groups">Groups</a> enable several client users of the same kind to be managed together
    * <a target="_blank" href="https://developer.hashicorp.com/vault/docs/concepts/lease">Leases</a> limit the lifetimes of TTL (Time To Live) granted to access resources
    * <a target="_blank" href="https://developer.hashicorp.com/vault/tutorials/cloud/vault-namespaces">Namespaces</a> (a licensed Enterprise "multi-tenancy" feature) separates access to data among several tenants (groups of users in unrelated groups)
    * <a target="_blank" href="https://developer.hashicorp.com/vault/tutorials/auth-methods/oidc-identity-provider">OIDC Provider</a> [<a target="_blank" href="https://developer.hashicorp.com/vault/docs/secrets/identity/oidc-provider">doc</a>]
    <br /><br />

    ISO 29115 defines "Identity" as a set of attributes related to an entity (human or machine).
    A person may have multiple identities, depending on the context (website accessed).


    <a name="EditPolicies"></a>

    ### &#9744; Edit Policies

    * <a target="_blank" href="https://developer.hashicorp.com/vault/tutorials/cloud/vault-policies">Policies</a> -- aka ACL (Access Control Lists) -- provide a declarative way to grant or forbid access to certain paths and operations in Vault. 


    <a name="AccessVaultCLI"></a>

    ### &#9744; Access Vault via CLI

    **Warning**: This application is publicly accessible, make sure to destroy the Kubernetes resources associated with the application when done.

41. Dynamically obtain credentials to the Vault cluster managed by HCP by running these commands on your Terminal:

    ```bash
    export VAULT_ADDR=$(terraform output --raw vault_public_url)
    export VAULT_TOKEN=$(terraform output --raw vault_root_token)
    export VAULT_namespace=admin
    ```
    An example of such values are:
    * VAULT_ADDR = "https://hcp-vault-public-vault-9577a2dc.993dfd61.z1.hashicorp.cloud:8200"
    <br /><br />

    The above variables are sought by Vault to authenticate client programs or custom applications.
    See <a target="_blank" href="https://developer.hashicorp.com/vault/tutorials?optInFrom=learn">HashiCorp's Vault tutorials</a>.

42. List secrets engines enabled within Vault:
    ```bash
    vault secrets list
    ```
    These commands are used to verify configuration for GitHub Actions.


    <a name="GitHubOIDC"></a>
    
    ### &#9744; Setup OIDC for GitHub Actions

42. <a target="_blank" href="https://www.youtube.com/watch?v=lsWOx9bzAwY">VIDEO</a>: 
    Obtain</a> a list of Authentication Methods setup, to ensure that "JWT" needed for GitHub is available:
    ```bash
    vault auth list
    ```
    The response includes:    
    <pre>Path    Type          Accessor           Description
    ---     ----          --------           -----------
    jwt/    jwt        auth_jwt_12345678     JWT Backend for GitHub Actions
    token/  ns_token   auth_ns_token_345678  token based credentials
    </pre>

    When GitHub presents a a JSON Web Token (JWT) containing the necessary combination of <a target="_blank" href="https://docs.github.com/en/enterprise-cloud@latest/actions/deployment/security-hardening-your-deployments/about-security-hardening-with-openid-connect#understanding-the-oidc-token">claims</a>, 
    the token exposes parameters (known as claims) which we can bind a Vault role against
    Vault returns an auth token for a given Vault role.

43. View settings:
    ```bash
    vault policy read github-actions-oidc
    ```

44. TODO: Terraform in this repo has <a target="_blank" href="https://docs.github.com/en/actions/deployment/security-hardening-your-deployments/configuring-openid-connect-in-hashicorp-vault">enabled</a> the JWT (Java Web Token) auth method so that:
    ```bash
    vault read auth/jwt/role/github-actions-role
    ```
    
    <pre><strong>vault auth list
    </strong></pre>
    The response includes:
    <pre>key                  Value
    ---                    -----------
    bound_audiences        [https://github.com/johndoe]
    bound_subject          repo:johndoe/repo1:ref:refs/heads/main
    bound_issuer           https://token.actions.githubusercontent.com/enterpriseSlug
    token_max_ttl          1m40s    
    ...
    </pre>

    The above is confirmed using this:
    ```bash
    vault write auth/jwt/config \
    ```
    The above was configured using this:
    ```bash
    resource "vault_jwt_auth_backend" "github_oidc" {
    description = "Accept OIDC authentication from GitHub Action workflows"
    path = "gha"
    bound_issuer="https://token.actions.githubusercontent.com/enterprise_name
    oidc_discovery_url="https://token.actions.githubusercontent.com/enterprise_name_
    }
    ```
    <a target="_blank" href="https://www.digitalocean.com/blog/fine-grained-rbac-for-github-action-workflows-hashicorp-vault">CAUTION</a>: 
    The above grants the entirety of public GitHub the possibility of authenticating to your Vault server. If bound claims are accidentally misconfigured, you could be exposing your Vault server to other users on github.com. So instead use <a target="_blank" href="https://docs.github.com/en/enterprise-cloud@latest/rest/actions/oidc?apiVersion=2022-11-28#set-the-github-actions-oidc-custom-issuer-policy-for-an-enterprise">an API-only</a>

    NOTE: This is NOT the <a target="_blank" href="https://developer.hashicorp.com/vault/docs/auth/github">GitHub login</a> <a target="_blank" href="https://developer.hashicorp.com/vault/api-docs/auth/github">Authentication Method</a> which enable <a target="_blank" href="https://wahlnetwork.com/2020/02/10/vault-auth-using-github-personal-tokens/">sign in to Vault using a PAT generated on GitHub.com</a>.

    Access to assets within GitHub.com are granted based <a target="_blank" href="https://github.com/settings/tokens">Personal Access Tokens</a> (PAT) generated within GitHub.com. Such credentials are static (do not expire), so are exposed to be stolen for reuse by an adversary.

    GitHub.com provides a <a target="_blank" href="https://res.cloudinary.com/dcajqrroq/image/upload/v1676743084/gha-secrets-2520x1488_d3x8az.jpg">"Actions Secrets" GUI</a> to store encrypted <strong>access tokens</strong> to access cloud assets outside GitHub. Variables to obtain secrets:

       * VAULT_ADDR
       * VAULT_NAMESPACE (when using HCP)
       * VAULT_ROLE
       * VAULT_SECRET_KEY
       * VAULT_SECRET_PATH
       <br /><br />

    PROBLEM: Such credentials are repeated stored in each GitHub repository. Rotation of the credentials would require going to each GitHub repo. Or if secrets are set at the enviornment, anyone with access to the enviornment would have access to the keys (secrets are not segmented).

    On <a target="_blank" href="https://github.blog/changelog/2021-10-27-github-actions-secure-cloud-deployments-with-openid-connect/">Oct. 2021 GitHub announced</a> its <strong>OIDC provider</strong>. OIDC stands for "OpenID Connect", <a target="_blank" href="https://openid.net/connect/faq/">spec defined</a> by the OpenID Foundation on February 26, 2014. OIDC solves the "Deleted Authorization Problem" of how to "provide a website access to my data without giving away my password". 

    Technically, OIDC standardizes <strong>authentication (AuthN)</strong>, which uses OAuth 2.0 for delegated authorization (AuthZ). 
    use of a ID token (JSON JWT format) with a UserInfo endpoint for getting more user information. It works like a badge at concerts.
    
    Vault creates OIDC credentials as a <a target="_blank" href="https://developer.hashicorp.com/vault/tutorials/auth-methods/oidc-identity-provider">OIDC Identity Provider</a> with a <a target="_blank" href="https://docs.github.com/en/actions/deployment/security-hardening-your-deployments/using-openid-connect-with-reusable-workflows">OIDC authorization (AuthZ) code flow</a> (grant type).

    What is passed through the network can be decoded using https://jsonwebtoken.io.
    A part of the transmission includes a cryptographic signature used to independently verify whether contents have been altered. The signature is created using an IETF JSON standard. OIDC provides a standard alternative to adaptations such as Facebook's "Signed Request" using a proprietary signature format.

    TODO: Automation in this repo has already <a target="_blank" href="https://developer.hashicorp.com/vault/docs/auth/github#configuration">configured Vault</a> to <strong>dynamically generate</strong> access credentials with a short <tt>lease_duration</tt> which becomes useless after that period of time. Such secrets are generated based on <a href="#Edit_tfvars">parameters defined in the tfvars file</a> used to automatically fill out the GUI  ACCESS: OIDC Provider: Create your first app form:<br />
    <a target="_blank" href="https://res.cloudinary.com/dcajqrroq/image/upload/v1676728555/vault-oidc-app-879x728_hpmqza.jpg"><img alt="vault-oidc-app-879x728.jpg" width="400" src="https://res.cloudinary.com/dcajqrroq/image/upload/v1676728555/vault-oidc-app-879x728_hpmqza.jpg"></a>
    
    TODO: Some variable names come from the configuration file for the JWT (Java Web Token) protocol, displayed using command:

    <pre><strong>vault read auth/jwt/config
    </strong></pre>

    The response include:
    
    <pre>key        Value
    ---        -----------
    bound_issuer           https://token.actions.githubusercontent.com
    </pre>


    See https://wilsonmar.github.io/github-actions about additional utilities (such as hadolint running .hadolint.yml).

    Within a GitHub Actions .yml file, a secret is requested from Vault <a target="_blank" href="https://www.youtube.com/watch?v=lsWOx9bzAwY&31m15s">VIDEO</a>: like <a target="_blank" href="https://github.com/ned1313/vault-oidc-github-actions/blob/main/.github/workflows/oidc_test.yml">this</a> during  debugging, NOT in PRODUCTION.

    

    <a name="AccessVaultAPI"></a>

    ### &#9744; Access Vault using API Programming

45. See tutorials about application programs interacting with Vault:

    * https://wilsonmar.github.io/hello-vault
    <br /><br />

    <a name="AccessEKS"></a>
    
    ### &#9744; Access the EKS Cluster:

46. Set the <strong>context</strong> within local file <tt>$HOME/.kube/config</tt> so local awscli and kubectl commands know the AWS ARN to access:
    ```bash
    aws eks --region us-west-2 update-kubeconfig \
    --name $(terraform output --raw eks_cluster_name)
    ```
47. Verify <a target="_blank" href="https://kubernetes.io/docs/concepts/configuration/organize-cluster-access-kubeconfig/">kubeconfig view</a> of information about details, certificate, and secret token to authenticate the Kubernetes cluster:
    ```bash
    kubectl config view
    ```

48. Verify <a target="_blank" href="https://kubernetes.io/docs/concepts/configuration/organize-cluster-access-kubeconfig/">kubeconfig view</a> of information about details, certificate, and secret token to authenticate the Kubernetes cluster:
    ```bash
    kubectl config get-contexts
    ```

49. Obtain the contents of a kubeconfig file into your Clipboard: ???
    ```bash
    terraform output --raw kubeconfig_filename | pbcopy
    ```
50. Paste from Clipboard and remove the file path to yield:

    <pre>apiVersion: v1
    kind: ConfigMap
    metadata:
    name: aws-auth
    namespace: kube-system
    data:
    mapRoles: |
        - rolearn: arn:aws:iam::123456789123:role/node_group_01-eks-node-group-12340214203844029700000001
        username: system:node:{{EC2PrivateDNSName}}
        groups:
            - system:bootstrappers
            - system:nodes
    </pre>

51. TODO: Set the `KUBECONFIG` environment variable ???

    <a name="ConfigPolicies"></a>
    ### &#9744; Configure Policies

    PROTIP: Configuring policies is at the core of what Administrators do to enhance security.

    https://developer.hashicorp.com/vault/tutorials/policies/policies


    <a name="CreateUsers"></a>

    ### &#9744; Create User Accounts

    Limit risk of lateral movement by hackers to do damage if elevated Administrator credentials are compromised.

41. Create an account for the Admininstrator to use when doing work as a developer or other persona. 

    TODO: 
42. TODO: "Userpass" static passwords? 

    https://developer.hashicorp.com/vault/docs/concepts/username-templating

    On developer machines, the GitHub auth method is easiest to use. 
    
    
    For servers the AppRole method is the recommended choice.
    https://developer.hashicorp.com/vault/docs/auth/approle


    https://developer.hashicorp.com/vault/docs/concepts/response-wrapping


    <a name="ConfigSecretsEngines"></a>    
    ### &#9744; Configure Secrets Engines



    <a name="VaultTools"></a>

    ### &#9744; Use Vault Tools GUI

43. Click <strong>Tools</strong> in the Vault menu to encrypt and decrypt pasted in then copied from your Clipboard.

    <a target="_blank" href="https://res.cloudinary.com/dcajqrroq/image/upload/v1676560621/hcp-tools-menu-103x239_iixqpz.jpg"><img width="103" height="239" src="https://res.cloudinary.com/dcajqrroq/image/upload/v1676560621/hcp-tools-menu-103x239_iixqpz.jpg"></a>





    <a name="KubeConfig"></a>

    ### &#9744; Configure Kube auth method for Vault:

55. Grab the kube auth info and stick it in ENVVARS:
    ```bash
    export TOKEN_REVIEW_JWT=$(kubectl get secret \
    $(kubectl get serviceaccount vault -o jsonpath='{.secrets[0].name}') \
    -o jsonpath='{ .data.token }' | base64 --decode)

    echo $TOKEN_REVIEW_JWT

    export KUBE_CA_CERT=$(kubectl get secret \
    $(kubectl get serviceaccount vault -o jsonpath='{.secrets[0].name}') \
    -o jsonpath='{ .data.ca\.crt }' | base64 --decode)

    echo $KUBE_CA_CERT

    export KUBE_HOST=$(kubectl config view --raw --minify --flatten \
    -o jsonpath='{.clusters[].cluster.server}')

    echo $KUBE_HOST
    ```

    ### &#9744; Continue with configuration of Vault and deployment of Postgres, Vault agent, and Hashicups app

56. Enable the auth method and write the Kubernetes auth info into Vault:
    ```bash
    vault auth enable kubernetes
    ```
    ```bash
    vault write auth/kubernetes/config \
    token_reviewer_jwt="$TOKEN_REVIEW_JWT" \
    kubernetes_host="$KUBE_HOST" \
    kubernetes_ca_cert="$KUBE_CA_CERT"
    ```

57. Deploy Postgres:
    ```bash 
    kubectl apply -f files/postgres.yaml
    ```

58. Check that Postgres is running:
    ```bash
    kubectl get pods
    ```

59. Grab the Postgres IP and then configure the Vault DB secrets engine:
    ```bash
    export POSTGRES_IP=$(kubectl get service -o jsonpath='{.status.loadBalancer.ingress[0].hostname}' postgres)

    echo $POSTGRES_IP
    ```

60. Enable DB secrets:
    ```bash
    vault secrets enable database
    ```

61. Write the Vault configuration for the postgresDB deployed earlier:
    ```bash
    vault write database/config/products \
        plugin_name=postgresql-database-plugin \
       allowed_roles="*" \
       connection_url="postgresql://{{username}}:{{password}}@${POSTGRES_IP}:5432/products?sslmode=disable" \
       username="postgres" \
       password="password"

    vault write database/roles/product \
       db_name=products \
       creation_statements="CREATE ROLE \"{{name}}\" WITH LOGIN PASSWORD '{{password}}' VALID UNTIL '{{expiration}}'; \
        GRANT SELECT ON ALL TABLES IN SCHEMA public TO \"{{name}}\";" \
       revocation_statements="ALTER ROLE \"{{name}}\" NOLOGIN;"\
       default_ttl="1h" \
       max_ttl="24h"
    ```

62. Ensure we can create credentials on the postgresDB with Vault:
    ```bash
    vault read database/creds/product
    ```

63. Create policy in Vault:
    ```bash
    vault policy write product files/product.hcl

    vault write auth/kubernetes/role/product \
        bound_service_account_names=product \
        bound_service_account_namespaces=default \
        policies=product \
        ttl=1h
    ```

64. Deploy the product app:
    ```bash
    kubectl apply -f files/product.yaml
    ```

65. Check the product app is running before moving on:
    ```bash
    kubectl get pods
    ```

66. Set into background job:
    ```bash
    kubectl port-forward service/product 9090 &
    ```

67. Test the app retrieves coffee info:
    ```bash
    curl -s localhost:9090/coffees | jq .
    ```

<hr />

<a name="DestroyVault"></a>

## Destroy Vault Instance

PROTIP: Because this repo enables a new Vault cluster to be easily created in HCP, there is less hesitancy about destroying them (to save money and avoid confusion).

1.  CAUTION: PROTIP: Save secrets data stored in your Vault instance before deleting. Security-minded enterprises transfer backup files to folders controlled by a different AWS account so that backups can't be deleted by the same account which created them.
2.  PROTIP: Well ahead of this action, notify all users and obtain their acknowledgments.

3.  <a href="#SignInHCP">Sign in HCP Portal GUI</a> as an Administrator, at the <strong>Overview</strong> page of your Vault instance in HCP.
4.  PROTIP: Click <strong>API Lock</strong> to stop all users from updating data in the Vault instance.

    NOTE: There is also a "<a target="_blank" href="https://developer.hashicorp.com/vault/tutorials/operations/emergency-break-glass-features">break glass</a>" procedure that <strong>seals</strong> the Vault server that physically blocks respose to all requests (with the exception of status checks and unsealing.discards its in-memory key for unlocking data).

5.  If you ran Terraform to create the cluster, there is no need to click <strong>Manage</strong> at the upper right for this menu:

    <a target="_blank" href="https://res.cloudinary.com/dcajqrroq/image/upload/v1675389154/vault-hcp-manage-drop-410x306_ehwn0c.jpg"><img width="400" src="https://res.cloudinary.com/dcajqrroq/image/upload/v1675389154/vault-hcp-manage-drop-410x306_ehwn0c.jpg"></a>

    If you used Terraform to create the cluster, DO NOT click the GUI red <strong>Delete cluster</strong> square nor type "DELETE" to confirm.

6.  In your Mac Terminal, set credentials for the same AWS account you used to create the cluster.
7.  <a href="#SelectExample">navigate to the folder</a> holding the <tt>sample.auto.tfvars</tt> file when Terraform was run.
8.  There should be files <tt>terraform.tfstate</tt> and <tt>terraform.tfstate.backup</tt>
    ```bash
    ls terraform.*
    ```
9.  Run:
    ```bash
    time terraform destroy -auto-respond
    ```
    Successful completion would be a response such as:
    <pre>module.hcp-eks.module.vpc.aws_vpc.this[0]: Destruction complete after 0s
    &nbsp;
    Destroy complete! Resources: 58 destroyed.
    terraform destroy -auto-approve  9.06s user 3.65s system 0% cpu 21:20.24 total
    </pre>
    Time to complete the command has been typically about 20-40 minutes.

10. Remove the files <tt>terraform.tfstate</tt> and <tt>terraform.tfstate.backup</tt>
    ```bash
    rm terraform.*
    ```
11. PROTIP: Send another notification to all users and obtain their acknowledgments.
12. If you saved the HCP Vault cluster URL to your browser bookmarks, remove it.

## References:

<a target="_blank" href="https://www.youtube.com/watch?v=FxcUf2spssE&t=282s">VIDEO: "HCP Vault: A Quickstart Guide"</a> (on a previous release with older GUI)

<!-- END -->

## Secure by Default

<strong>Automation and defaults</strong> in this repo minimize the <a target="_blank" href="https://developer.hashicorp.com/vault/tutorials/cloud/get-started-vault">manual effort</a> otherwise needed to create <strong>enterprise-worthy secure production</strong> environments.

Use <strong>pre-defined</strong> Terraform <strong>modules</strong> which have been reviewed by several experienced professionals to contain secure defaults and mechanisms for <a target="_blank" href="https://developer.hashicorp.com/vault/tutorials/operations/production-hardening">security hardening</a> that include:

   * RBAC settings by <strong>persona</strong> for Least-privilege permissions (separate accounts to read but not delete)

   * Verification and automated implementation of the latest TLS certificate version and Customer-provided keys
   * End-to-End encryption to protect communications, logs, and all data at rest
   * Automatic dropping of invalid headers
   * Logging enabled for audit and forwarding
   * Automatic movement of logs to a SIEM (such as Splunk) for analytics and alerting
   * Automatic purging of logs to conserve disk space usage
   * Purge protection (waiting periods) on KMS keys and Volumes

   * Enabled automatic secrets rotation, auto-repair, auto-upgrade
   * Disabled operating system swap to prevent the from paging sensitive data to disk. This is especially important when using the integrated storage backend.
   * Disable operating system core dumps which may contain sensitive information
   * etc.
   <br /><br />

Let's start by looking at the structure of the repo's folders and files.

<a name="RepoFolders"></a>

## Repo folders and files

At the root of the repo, a folder is created for each cloud (AWS, Azure, GCP).

Within each cloud folder is a folder for each <strong>environment</strong>: "dev" (development) and "prd" (for production) use.

Within each of environment folders is an <tt>examples</tt> folder for each alternative configuration you want created.

As is the industry custom for Terraform, a sample file is provided so you can rename <tt>sample.auto.tfvars</tt> to customize values to be used for your desired set of resources.

## Structure of GitHub repositories

   Many enterprises create <strong>"Doormat"</strong> type systems to create new credentials that are good only for a short time for those who have been validated by an <strong>IdP</strong> (Identity Provider) system such as Okta. 

   ## Credentials to infra accounts

   Credentials with enough permissions are needed to create resources in each cloud. For AWS, that means creating for each account <a href="#SetAWSEnv">AWS credentials set</a> as environment variables or in a credentials file for AWS to read.


This repository, at <a target="_blank" href="https://github.com/stoffee/csp-k8s-hcp/">https://github.com/stoffee/csp-k8s-hcp</a> provides the custom Terraform HCL (HashiCorp Language) files (with a <tt>.tf</tt> suffix) to 




Additionally, templates and the resources they reference are also stored in the registry.

## GitHub repos

Since this presentation is focused on <strong>enterprise</strong> production environments, we assume that there is a segregation of responsibilities among different <strong>central</strong> work groups common within large organizations.

   The number of and naming of custom code repositories holding Terraform often reflects organizational divisions (see <a target="_blank" href="https://en.wikipedia.org/wiki/Conway%27s_law">"Conway's Law"</a>).

   In large organizations, the repositories containing Terraform:

   * A <strong>tools-install</strong> repo to establish utility programs on the laptop of a DevSecOps administrator, to minimize frustration
   * A <strong>pre-requisites</strong> repo to establish core cloud services and ensure they are working (one repo per cloud vendor)
   * A different repo for each product (HashiCorp Vault, Consul, etc.) because different teams create them
   * Additional add-on functionality and systems
   <br /><br />

   WARNING: Using multiple repos to install services under the same account is that you need to remember which repo (state file) created which resources.


TODO: github.com different strategies for managing state files ..


   <a target="_blank" href="https://developer.hashicorp.com/terraform/cloud-docs">Terraform Cloud</a> enables <strong>Private</strong> objects in the HashiCorp Registry.

   Additionally, there are <a target="_blank" href="https://www.hashicorp.com/products/terraform/pricing">several licensed editions</a> (with free trial periods):

   Cloud "Team" plan adds:
     * Role-based access and Team Management
   Cloud "Team & Governance" plan adds:
     * Configuration designer
     * Cross-organization registry sharing
     * Cost estimation
     * Policy as code (Sentinel or OPA)
     * Run tasks: Advisory enforcement
     * Policy enforcement
    Cloud "Business" plan adds:
     * SSO
     * Team Management
     * Drift detection
     * Audit logging
     * ServiceNow integration
    Enterprise level plan adds:
    * Runtime metrics (Prometheus)
    * Air gap network deployment
    * Application-level logging
    * Log forwarding
    <br /><br />

   https://app.terraform.io/signup


## Modules

For example, AWS HashiCorp established its "terraform-aws-modules/" TODO:

Each cloud vendor has its own way to provide <strong>cloud services</strong>.
In AWS, these are typical Terraform modules:

   <table border="1" cellpadding="4" cellspacing="0">
   <tr><th> module name </th><th> AWS </th><th> terraform-aws-modules/ </th><th> note </th></tr>
   <tr valign="top"><td> database </td><td> _rds </td><td> rds-aurora/aws </td><td> aurora-postgresql </td></tr>
   <tr valign="top"><td> iam </td><td> _iam </td><td> Identity and Access Management </td></tr>
   <tr valign="top"><td> kms </td><td> _kms </td><td> Key Management </td></tr>
   <tr valign="top"><td> load-balancing </td><td> _ingress </td><td> - </td></tr>
   <tr valign="top"><td> networking     </td><td> networks </td><td> - </td></tr>
   <tr valign="top"><td> s3             </td><td> s3 </td><td> Objects (files) in Buckets </td></tr>
   <tr valign="top"><td> secrets-manager </td><td> _manager </td><td> - </td></tr>
   </table>


## Examples

<a href="#Edit_tfvars">edit options in sample.auto.tfvars</a> to configure values for variables used in Terraform runs.

   * <a href="#SelectExample">Select Example Deploy</a>
   * <a href="#ProductionDeploy">Production Deploy</a>
   <br /><br />

   <strong>"Feature flags"</strong> -- variables with true or false values defining whether a Kubernetes add-on or some feature is optionally included or excluded in a particular install, such as:

   * VPC, DNS, and other networking "prerequisite" resources
   * Verification of endpoints
   * Observability Extraction (Prometheus)
   * Analytics (dashboarding) of metrics (Grafana)
   * Scaling (Kubernetes Operator <a target="_blank" href="https://karpenter.sh/">Karpenter</a> or cluster-autocaler) to provision Kubernetes nodes of the right size for

