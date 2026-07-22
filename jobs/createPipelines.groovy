def repoUrl = "https://github.com/gsharma1298/Microservices-E-Commerce-eks-project.git"

def pipelineFiles = [
    "adservice-jenkinsfile",
    "cartservice-jenkinsfile",
    "checkoutservice-jenkinsfile",
    "currencyservice-jenkinsfile",
    "emailservice-jenkinsfile",
    "frontend-jenkinsfile",
    "loadgenerator-jenkinsfile",
    "paymentservice-jenkinsfile",
    "productcatalogservice-jenkinsfile",
    "recommendationservice-jenkinsfile",
    "shippingservice-jenkinsfile"
]

pipelineFiles.each { file ->

    def jobName = file.replace("-jenkinsfile", "")

    pipelineJob(jobName) {

        description("Auto-generated Pipeline for ${jobName}")

        logRotator {
            numToKeep(10)
        }

        definition {
            cpsScm {
                scm {
                    git {
                        remote {
                            url(repoUrl)
                        }
                        branch("*/master")
                    }
                }
                scriptPath("jenkinsfiles/${file}")
            }
        }
    }
}
