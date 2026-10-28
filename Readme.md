# Cloud-Native Microservices Platform

## Project Name

**Cloud-Native Microservices Platform**: Automated E-Commerce Deployment Platform

---

## Project Idea

### Problem Addressed

E-commerce websites often suffer from downtime and error-prone manual deployments, especially during traffic spikes.

### Description

Deploy a multi-service e-commerce platform (web frontend, product search, payment, and database services) using automated CI/CD, containerization, Kubernetes orchestration, monitoring, and infrastructure provisioning on AWS. The focus is on DevOps pipelines, scalability, and reliability rather than application complexity. The payment service is simulated.

### Deliverables

1. Dockerized e-commerce microservices (web, product/search, payment)
2. CI/CD pipeline for automated updates (GitHub Actions)
3. Kubernetes deployment for scalability
4. Nginx for web application access
5. Prometheus and Grafana dashboards for service monitoring
6. Terraform scripts for AWS infrastructure (EC2, S3)
7. Ansible scripts for server setup and configuration
8. Automated rollback strategy
9. Git repository for code and scripts

### Tools

GitHub Actions, Docker, Kubernetes, Prometheus, Grafana, Ansible, Terraform, AWS EC2/S3, Nginx, Git

---

## Team Members

| #   | Name                           |
| --- | ------------------------------ |
| 1   | Amr Atef Abdullah              |
| 2   | Omar Elsayed Mohamed Mahfouz   |
| 3   | Ezzeldine Mohamed Mahmoud Kotb |
| 4   | Mariam Abed                    |
| 5   | Ali Ahmed Elhusseiny           |
| 6   | Judy Assem                     |

---

## Work Plan

**Project ready by:** December 1, 2026

| Phase                             | Period            | Main Tasks                                                                                                 |
| --------------------------------- | ----------------- | ---------------------------------------------------------------------------------------------------------- |
| 1. Planning & Documentation       | Oct 22 – Oct 28   | Finalize project scope, architecture, and README; set up repository structure and branching strategy       |
| 2. Application & Containerization | Oct 29 – Nov 4    | Build the microservices (web, product/search, payment); write Dockerfiles; run locally with Docker Compose |
| 3. CI/CD & Infrastructure as Code | Nov 5 – Nov 11    | GitHub Actions pipeline (build and push images); Terraform for AWS (EC2, S3)                               |
| 4. Configuration & Orchestration  | Nov 12 – Nov 18   | Ansible playbooks for server setup; Kubernetes manifests; Nginx                                            |
| 5. Monitoring & Rollback          | Nov 19 – Nov 25   | Prometheus and Grafana dashboards; automated rollback strategy                                             |
| Final Demo                        | First week of Dec | Project will be ready in first week of Dec                                                                 |

---

## Roles & Responsibilities

| Team Member                    | Role                                 | Responsibilities                                                                                           |
| ------------------------------ | ------------------------------------ | ---------------------------------------------------------------------------------------------------------- |
| Amr Atef Abdullah              | DevOps Engineer                      | Docker, Docker Compose, and collaboration on Kubernetes, Terraform, and monitoring.                        |
| Omar Elsayed Mohamed Mahfouz   | Frontend Developer & DevOps Engineer | Frontend development and integration with backend APIs.                                                    |
| Ezzeldine Mohamed Mahmoud Kotb | DevOps Team Member                   | Collaboration on Kubernetes, Terraform, and monitoring.                                                    |
| Mariam Abed                    | Backend Developer & DevOps Engineer  | Backend development, API implementation, and database integration.                                         |
| Ali Ahmed Elhusseiny           | DevOps Team Member                   | Collaboration on Kubernetes, Terraform, and monitoring.                                                    |
| Judy Assem                     | CI/CD Engineer                       | CI/CD pipeline implementation and automation, with collaboration on Kubernetes, Terraform, and monitoring. |

---

## KPIs

| KPI                                             | Target                                            |
| ----------------------------------------------- | ------------------------------------------------- |
| Deployment time (push to running in production) | Under 10 minutes                                  |
| CI/CD pipeline success rate                     | Above 90%                                         |
| Rollback time after a failed deployment         | Under 2 minutes                                   |
| Scalability                                     | Services run with multiple replicas on Kubernetes |
| Availability during deployments                 | Zero downtime (rolling updates)                   |
| Infrastructure provisioning                     | Fully created with Terraform in a single run      |
| Monitoring coverage                             | All services monitored with dashboards in Grafana |

---

## Instructor

**Ahmed Gamil**
