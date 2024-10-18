pipeline{
    agent { label 'terraform'}
    parameters{
        choice(name: 'ENV', choices: ['dev', 'prod'], description: 'select environment')
    }
    options{
        ansiColor('xterm') 
    }

    stages{
        stage('terraform init'){
            steps{
            sh 'terraform init --backend-config=${ENV}-env/state.tfvars'
            }
        }
        stage('terraform plan'){
            input{
                message "Should we continue?"
            }
            steps{
            sh 'terraform plan --var-file=${ENV}-env/input.tfvars'
            }
        }
         
    }
}