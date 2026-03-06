# 🏋️ FitZone Gym App

A microservices-based gym management application deployed across **4 Docker containers** on **Azure Cloud**.

## Architecture

```
┌─────────────────────────────────────────────────────┐
│                 Azure Container Group                │
│                                                     │
│  ┌─────────────┐  ┌──────────────┐  ┌────────────┐ │
│  │ gym-booking  │  │gym-membership│  │gym-notifier│ │
│  │   :4001      │  │    :4002     │  │   :4003    │ │
│  └──────┬───────┘  └──────┬───────┘  └─────▲──────┘ │
│         │                 │                │        │
│         └────────┬────────┘         notifications   │
│                  │                                  │
│         ┌────────▼────────┐                         │
│         │  gym-frontend   │ ◄── Public :3000        │
│         │  (Nginx+React)  │                         │
│         └─────────────────┘                         │
└─────────────────────────────────────────────────────┘
```

| Container | Description | Port |
|-----------|-------------|------|
| `gym-frontend` | React SPA served by Nginx (reverse proxy) | 3000 |
| `gym-booking` | Class booking API (Node.js/Express) | 4001 |
| `gym-membership` | Membership & plans API (Node.js/Express) | 4002 |
| `gym-notifier` | Notification event store (Node.js/Express) | 4003 |

## Quick Start — Local (Docker Compose)

```bash
# Build and run all 4 containers
docker-compose up --build

# Open in browser
# http://localhost:3000
```

## Deploy to Azure

### Prerequisites
- [Docker](https://docs.docker.com/get-docker/) installed locally
- [Azure CLI](https://learn.microsoft.com/en-us/cli/azure/install-azure-cli) installed
- An active Azure subscription

### Deploy

```powershell
# Run the deployment script
.\deploy\deploy.ps1

# With custom parameters
.\deploy\deploy.ps1 -ResourceGroup "my-gym-rg" -Location "westus2"
```

The script will:
1. Create an Azure Resource Group
2. Create an Azure Container Registry (ACR)
3. Build and push all 4 Docker images
4. Deploy to Azure Container Instances via Bicep
5. Output the public URL

### Clean Up

```powershell
# Delete all Azure resources
az group delete --name gym-app-rg --yes --no-wait
```

## API Endpoints

### Booking Service (`:4001`)
| Method | Endpoint | Description |
|--------|----------|-------------|
| GET | `/api/classes` | List gym classes |
| POST | `/api/bookings` | Book a class |
| GET | `/api/bookings` | List bookings |
| DELETE | `/api/bookings/:id` | Cancel booking |
| GET | `/health` | Health check |

### Membership Service (`:4002`)
| Method | Endpoint | Description |
|--------|----------|-------------|
| GET | `/api/plans` | List membership plans |
| POST | `/api/members` | Register member |
| GET | `/api/members` | List members |
| GET | `/api/stats` | Dashboard statistics |
| GET | `/health` | Health check |

### Notification Service (`:4003`)
| Method | Endpoint | Description |
|--------|----------|-------------|
| POST | `/api/notify` | Send notification |
| GET | `/api/notifications` | List notifications |
| GET | `/health` | Health check |
