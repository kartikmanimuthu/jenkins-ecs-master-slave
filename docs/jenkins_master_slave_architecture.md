# Jenkins Master-Slave Architecture

Jenkins can be configured in a distributed manner, where the workload is offloaded from the main Jenkins server (master) to other machines (agents or slaves). This architecture offers several benefits:

- **Scalability**: Distribute build and test workloads across multiple agents to handle increased demand.
- **Isolation**: Run different types of builds (e.g., different operating systems, specific software versions) on dedicated agents without interfering with each other.
- **Resource Optimization**: Utilize diverse hardware resources more efficiently.

## Components:

### Jenkins Master

The Jenkins Master is the central controlling unit of the Jenkins environment. Its responsibilities include:

- **Scheduling builds**: Orchestrates and dispatches build jobs to available agents.
- **Monitoring agents**: Keeps track of the status and availability of connected agents.
- **Storing configurations**: Manages global Jenkins settings, job configurations, and build history.
- **Providing the user interface**: Hosts the web interface for users to interact with Jenkins.

### Jenkins Agent (Slave)

Jenkins Agents are machines (physical or virtual) that perform the actual work of building and testing projects. They connect to the Jenkins Master and execute jobs as instructed. Agents typically:

- **Execute build steps**: Run scripts, compile code, execute tests, and perform other tasks defined in a Jenkins job.
- **Report status**: Send build results and logs back to the Jenkins Master.
- **Are disposable**: In cloud environments like ECS, agents can be provisioned on-demand and terminated after use, optimizing cost and resource utilization.

## How they communicate:

The Jenkins Master and Agents communicate primarily through Java Network Launch Protocol (JNLP) or SSH. In the context of ECS, JNLP is commonly used.

- **JNLP (Java Network Launch Protocol)**: This is a protocol that allows a Java application to be launched from a remote web server. In Jenkins, the master provides a JNLP file that the agent downloads and executes. This file contains connection details, allowing the agent to establish a connection back to the master.

When an agent connects via JNLP, it typically:
1. Downloads the agent executable (`agent.jar`) from the Jenkins Master.
2. Connects back to the master using the JNLP protocol, often over a specific port (e.g., 50000).
3. Authenticates itself with the master.
4. Becomes available to execute jobs.

This setup allows for dynamic provisioning of agents, which is ideal for cloud environments where resources can be scaled up or down based on demand.
