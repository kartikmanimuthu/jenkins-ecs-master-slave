from diagrams import Diagram, Cluster
from diagrams.aws.compute import ECS, Fargate, ECR
from diagrams.aws.network import ALB
from diagrams.aws.storage import EFS
from diagrams.aws.management import Cloudwatch

with Diagram("Jenkins on AWS ECS", show=False, direction="LR"):
    # Using a generic node to represent the user browser
    from diagrams import Node
    user_browser = Node("User Browser", shape="none", height="0.5", width="1.0")
    
    with Cluster("User Interaction"):
        alb = ALB("Application Load Balancer")
        user_browser >> alb

    with Cluster("AWS Cloud"):
        with Cluster("VPC"):
            with Cluster("Public Subnets"):
                alb >> ECS("Jenkins Master ECS Service")

            with Cluster("Private Subnets"):
                jenkins_master_task = Fargate("Jenkins Master Task")
                jenkins_agent_service = ECS("Jenkins Agent ECS Service")
                jenkins_agent_task_1 = Fargate("Jenkins Agent Task 1")
                jenkins_agent_task_2 = Fargate("Jenkins Agent Task 2")
                efs = EFS("Persistent Storage")

                alb >> jenkins_master_task
                jenkins_master_task >> jenkins_agent_service
                jenkins_agent_service >> [jenkins_agent_task_1, jenkins_agent_task_2]

                jenkins_master_task >> efs
                jenkins_agent_task_1 >> efs
                jenkins_agent_task_2 >> efs

        with Cluster("AWS Services"):
            ecr_master = ECR("ECR - Master Image")
            ecr_agent = ECR("ECR - Agent Image")
            cloudwatch = Cloudwatch("CloudWatch Logs")

            ecr_master >> jenkins_master_task
            ecr_agent >> [jenkins_agent_task_1, jenkins_agent_task_2]
            [jenkins_master_task, jenkins_agent_task_1, jenkins_agent_task_2] >> cloudwatch
