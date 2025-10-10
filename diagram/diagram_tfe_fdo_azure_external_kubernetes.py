from diagrams import Cluster, Diagram
from diagrams.onprem.compute import Server


from diagrams.azure.compute import KubernetesServices
from diagrams.azure.database import DatabaseForPostgresqlServers,CacheForRedis
from diagrams.azure.storage import BlobStorage
from diagrams.azure.network import LoadBalancers





# Variables
title = "VNET with 1 public subnet for the Kubernetes \ and 2 private subnets for PostgreSQL and Redis."
outformat = "png"
filename = "diagram_tfe_fdo_azure_external_kubernetes"
direction = "TB"


with Diagram(
    name=title,
    direction=direction,
    filename=filename,
    outformat=outformat,
) as diag:
    # Non Clustered
    user = Server("user")

    # Cluster 
    with Cluster("Azure"):
        bucket_tfe = BlobStorage("TFE bucket")
        with Cluster("vpc"):
    
            with Cluster("Availability Zone: \n\n  "):
                # Subcluster 
                with Cluster("subnet_public1"):
                    loadbalancer1 = LoadBalancers("loadbalancer")    
                    Kubernetes_TFE = KubernetesServices("Kubernetes TFE")
                with Cluster("subnet_private1"):
                     postgresql = DatabaseForPostgresqlServers("RDS Instance")
                with Cluster("subnet_private2"):
                     Redis = CacheForRedis("Redis Instance")     
               
    # Diagram

    user >> [loadbalancer1] >> Kubernetes_TFE
   
    Kubernetes_TFE >> [postgresql,
                       bucket_tfe,
                       Redis] 

diag
