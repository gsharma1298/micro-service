def repoUrl = "git@github.com:gsharma1298/Microservices-E-Commerce-eks-project.git"
def branch = "master"
def credentialId = "github-ssh"   // Change this to your Jenkins GitHub SSH credential ID

def pipelines = [
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

pipelines.each { file ->

    def jobName = file.replace("-jenkinsfile", "")

    pipelineJob(jobName) {

        description("Pipeline for ${jobName}")

        logRotator {
            daysToKeep(15)
            numToKeep(20)
        }

        definition {
            cpsScm {
                scm {
                    git {
                        remote {
                            url(repoUrl)
                            credentials(credentialId)
                        }
                        branch(branch)
                    }
                }
                scriptPath("jenkinsfiles/${file}")
            }
        }

        triggers {
            scm('H/5 * * * *')
        }
    }
}
