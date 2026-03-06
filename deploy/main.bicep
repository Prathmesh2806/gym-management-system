// ──────────────────────────────────────────────────────────────────────
// Azure Bicep Template — Gym App Container Group (ACI)
// Deploys 4 containers in a single Azure Container Instance group
// ──────────────────────────────────────────────────────────────────────

@description('Name of the container group')
param containerGroupName string = 'gym-app-containers'

@description('Azure region for the deployment')
param location string = resourceGroup().location

@description('Azure Container Registry login server (e.g. myregistry.azurecr.io)')
param acrLoginServer string

@description('Azure Container Registry username')
param acrUsername string

@secure()
@description('Azure Container Registry password')
param acrPassword string

@description('Docker image tag to deploy')
param imageTag string = 'latest'

// ── Container Group ──────────────────────────────────────────────────
resource containerGroup 'Microsoft.ContainerInstance/containerGroups@2023-05-01' = {
  name: containerGroupName
  location: location
  properties: {
    osType: 'Linux'
    restartPolicy: 'OnFailure'

    // ACR credentials
    imageRegistryCredentials: [
      {
        server: acrLoginServer
        username: acrUsername
        password: acrPassword
      }
    ]

    // ── Containers ─────────────────────────────────────────────────────
    containers: [
      // 1. gym-notifier
      {
        name: 'gym-notifier'
        properties: {
          image: '${acrLoginServer}/gym-notifier:${imageTag}'
          ports: [
            { port: 4003, protocol: 'TCP' }
          ]
          environmentVariables: [
            { name: 'PORT', value: '4003' }
          ]
          resources: {
            requests: {
              cpu: json('0.5')
              memoryInGB: json('0.5')
            }
          }
        }
      }

      // 2. gym-booking
      {
        name: 'gym-booking'
        properties: {
          image: '${acrLoginServer}/gym-booking:${imageTag}'
          ports: [
            { port: 4001, protocol: 'TCP' }
          ]
          environmentVariables: [
            { name: 'PORT', value: '4001' }
            { name: 'NOTIFIER_URL', value: 'http://localhost:4003' }
          ]
          resources: {
            requests: {
              cpu: json('0.5')
              memoryInGB: json('0.5')
            }
          }
        }
      }

      // 3. gym-membership
      {
        name: 'gym-membership'
        properties: {
          image: '${acrLoginServer}/gym-membership:${imageTag}'
          ports: [
            { port: 4002, protocol: 'TCP' }
          ]
          environmentVariables: [
            { name: 'PORT', value: '4002' }
            { name: 'NOTIFIER_URL', value: 'http://localhost:4003' }
          ]
          resources: {
            requests: {
              cpu: json('0.5')
              memoryInGB: json('0.5')
            }
          }
        }
      }

      // 4. gym-frontend
      {
        name: 'gym-frontend'
        properties: {
          image: '${acrLoginServer}/gym-frontend:${imageTag}'
          ports: [
            { port: 3000, protocol: 'TCP' }
          ]
          resources: {
            requests: {
              cpu: json('0.5')
              memoryInGB: json('0.5')
            }
          }
        }
      }
    ]

    // Expose frontend port publicly
    ipAddress: {
      type: 'Public'
      dnsNameLabel: containerGroupName
      ports: [
        { port: 3000, protocol: 'TCP' }
      ]
    }
  }
}

// ── Outputs ──────────────────────────────────────────────────────────
output containerGroupFqdn string = containerGroup.properties.ipAddress.fqdn
output containerGroupIp string = containerGroup.properties.ipAddress.ip
