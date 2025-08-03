import jenkins.model.Jenkins
import hudson.Plugin
import java.lang.reflect.Method

// Extended wait time for plugin loading
def maxAttempts = 60 // 60 seconds
def attempt = 0
def pluginInstalled = false
def ecsCloudClass = null
def ecsTaskTemplateClass = null

while (attempt < maxAttempts && !pluginInstalled) {
    try {
        def pluginManager = Jenkins.instance.pluginManager
        def plugin = pluginManager.getPlugin("amazon-ecs")
        if (plugin != null && plugin.getWrapper().isActive()) {
            println "Amazon ECS plugin is installed and active."
            pluginInstalled = true
            // Use uberClassLoader for robust class loading
            ecsCloudClass = Jenkins.instance.pluginManager.uberClassLoader.loadClass("com.amazonaws.ecs.ECSCloud")
            ecsTaskTemplateClass = Jenkins.instance.pluginManager.uberClassLoader.loadClass("com.amazonaws.ecs.ECSTaskTemplate")
            println "ECSCloud and ECSTaskTemplate classes loaded successfully."
        } else {
            println "Amazon ECS plugin not yet active. Waiting... (Attempt ${attempt + 1}/${maxAttempts})"
            Thread.sleep(1000) // Wait for 1 second
        }
    } catch (ClassNotFoundException e) {
        println "Classes not found yet. Waiting... (Attempt ${attempt + 1}/${maxAttempts})"
        Thread.sleep(1000) // Wait for 1 second
    } catch (Exception e) {
        println "Error checking plugin status: ${e.getMessage()}. Waiting... (Attempt ${attempt + 1}/${maxAttempts})"
        Thread.sleep(1000) // Wait for 1 second
    }
    attempt++
}

if (!pluginInstalled) {
    println "Amazon ECS plugin did not become active within the expected time. Manual configuration may be required."
    return // Exit if plugin not active
}

// Simplified task template creation with minimal required configuration
def instance = Jenkins.instance

// Check if a cloud with the name "ecs-cloud" already exists
def ecsCloud = instance.clouds.find { it.name == "ecs-cloud" }

if (ecsCloud == null) {
    // Create a new ECSCloud instance using reflection
    // This assumes a constructor that takes a name, credentialsId, regionName, cluster, jenkinsUrl, tunnel
    // Adjust constructor parameters based on actual ECSCloud constructor
    try {
        def constructor = ecsCloudClass.getConstructor(String.class, String.class, String.class, String.class, String.class, String.class)
        ecsCloud = constructor.newInstance("ecs-cloud", "", System.getenv("AWS_REGION"), System.getenv("ECS_CLUSTER_NAME"), System.getenv("JENKINS_URL"), System.getenv("JENKINS_TUNNEL"))
        instance.clouds.add(ecsCloud)
        println "Created new ECS Cloud: ecs-cloud"
    } catch (NoSuchMethodException e) {
        println "Could not find a suitable constructor for ECSCloud. Please check the plugin version and its API. Error: ${e.getMessage()}"
        println "Fallback: Please configure the ECS cloud manually via Jenkins UI."
        return
    } catch (Exception e) {
        println "Error creating ECS Cloud instance: ${e.getMessage()}"
        println "Fallback: Please configure the ECS cloud manually via Jenkins UI."
        return
    }
} else {
    println "ECS Cloud 'ecs-cloud' already exists. Updating existing configuration."
    // You might want to update existing cloud configuration here if needed
}

// Add a task template if it doesn't exist
def templateName = "fargate-agent"
def existingTemplate = ecsCloud.templates.find { it.templateName == templateName }

if (existingTemplate == null) {
    try {
        // Create a new ECSTaskTemplate instance using reflection
        // This assumes a constructor that takes label, image, launchType, cpu, memory, executionRole, taskrole, subnets, securityGroups, logDriver, logDriverOptions, assignPublicIp, templateName, platformVersion
        // Adjust constructor parameters based on actual ECSTaskTemplate constructor
        def templateConstructor = ecsTaskTemplateClass.getConstructor(
            String.class, String.class, String.class, int.class, int.class, String.class, String.class, String.class, String.class, String.class, List.class, boolean.class, String.class, String.class
        )

        def logOptionsList = []
        def logGroupOption = ecsTaskTemplateClass.getMethod("newLogDriverOption", String.class, String.class).invoke(null, "awslogs-group", System.getenv("AGENT_LOG_GROUP"))
        def logRegionOption = ecsTaskTemplateClass.getMethod("newLogDriverOption", String.class, String.class).invoke(null, "awslogs-region", System.getenv("AWS_REGION"))
        def logStreamPrefixOption = ecsTaskTemplateClass.getMethod("newLogDriverOption", String.class, String.class).invoke(null, "awslogs-stream-prefix", "jenkins-agent")
        logOptionsList.add(logGroupOption)
        logOptionsList.add(logRegionOption)
        logOptionsList.add(logStreamPrefixOption)


        def ecsTaskTemplate = templateConstructor.newInstance(
            "ecs-agent", // label
            System.getenv("JENKINS_AGENT_IMAGE"), // image
            "FARGATE", // launchType
            System.getenv("AGENT_CPU") as int, // cpu
            System.getenv("AGENT_MEMORY") as int, // memory
            System.getenv("AGENT_EXECUTION_ROLE_ARN"), // executionRole
            System.getenv("AGENT_TASK_ROLE_ARN"), // taskrole
            System.getenv("PRIVATE_SUBNETS"), // subnets
            System.getenv("AGENT_SECURITY_GROUPS"), // securityGroups
            "awslogs", // logDriver
            logOptionsList, // logDriverOptions
            false, // assignPublicIp
            templateName, // templateName
            "LATEST" // platformVersion
        )
        ecsCloud.addTemplate(ecsTaskTemplate)
        println "Added new ECS Task Template: ${templateName}"
    } catch (NoSuchMethodException e) {
        println "Could not find a suitable constructor for ECSTaskTemplate or newLogDriverOption method. Please check the plugin version and its API. Error: ${e.getMessage()}"
        println "Fallback: Please configure the ECS task template manually via Jenkins UI."
        return
    } catch (Exception e) {
        println "Error creating ECS Task Template instance: ${e.getMessage()}"
        println "Fallback: Please configure the ECS task template manually via Jenkins UI."
        return
    }
} else {
    println "ECS Task Template '${templateName}' already exists. Skipping creation."
}

instance.save()
println "Jenkins configuration saved."
