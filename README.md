# 📋 DevOps To-Do List Web App

Welcome to my DevOps playground! This is a simple To-Do list web application built specifically to practice, develop, and refine my SDLC, Cloud, and Infrastructure engineering skills. 

While the application itself is a straightforward To-Do tracker with authentication, the primary focus of this repository is the pipeline, infrastructure, and deployment architecture behind the scenes.

---

## 🌍 **Live Demo:** [https://onlytodo.xyz](https://onlytodo.xyz)
**⏳ Demo notice:** To conserve AWS credits, the live environment is ephemeral. The infrastructure is automated to be available on a strict schedule and is <u>*only accessible between 09:30 and 17:30 each day Bangkok time (UTC+7)*</u>. Outside of these hours, **the entire infrastructure will be detroyed** before being created again the next day. If you want to check it out, please do so in the specified time.

## ⚠️ Project Status & Other important Notes

* **Work in Progress:** This is an active, ongoing project. You will likely see active refactoring, code cleaning, and bug fixing happening as I continue to build and learn.
* **Budget Constraints:** This architecture is built utilizing the AWS Free Tier and promotional credits. Because of these strict cost limitations, certain critical production elements such as highly available multi-AZ deployments, advanced security layers, and comprehensive logging may be compromised or scaled back, despite known best practices.
* **Known Anti-Patterns:** For the same cost-saving reasons mentioned above, you may spot some architectural anti-patterns that would normally be avoided in a production environment.
* **Evolving Tech Stack:** The tools listed below represent the current state of the project. Tools may be removed, swapped, or added as the project evolves. **(Note: Kubernetes is next on the roadmap and will be added soon!)**

---

## 🛠️ Current Tech Stack

### Web Development
* **Frontend:** SvelteKit
* **Backend:** Go

### Database
* **RDBMS:** PostgreSQL

### Containerization & Orchestration
* **Containers:** Docker
* **Orchestration:** Kubernetes *(Coming Soon!)*

### Infrastructure & Configuration
* **Cloud Provider:** AWS
* **Infrastructure as Code (IaC):** Terraform
* **Configuration Management:** Ansible

### CI/CD & Testing
* **Pipeline:** GitLab CI/CD
* **Testing:** Playwright (E2E Testing)

### Monitoring & Observability
* **Metrics:** Prometheus
* **Dashboards:** Grafana
