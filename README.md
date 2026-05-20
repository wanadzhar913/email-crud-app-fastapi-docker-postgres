This is a simple CRUD app for emails. We're using FastAPI, Docker, Postgres, and a plain HTML/CSS/JS frontend. Mainly built to practise AWS!

![Frontend UI screenshot](/assets/email_crud_app_frontend.png)

# Starting the application
Make sure you've got Docker installed on your system!

```bash
docker compose up --build
```

- **Frontend (UI):** http://localhost:8080
- **Backend (API):** http://localhost:8000 — docs at `/docs`, project metadata at `/api/project/`

Copy `.env.sample` to `.env` and set `PROJECT_TITLE`, `PROJECT_VERSION`, and `PROJECT_DESCRIPTION`; the UI loads these from the API.

# Deployment on AWS



# Resources
- https://medium.com/@sayalishewale12/complete-guide-to-creating-and-pushing-docker-images-to-amazon-ecr-70b67ac1ab4c#:~:text=Go%20back%20to%20the%20AWS,south%2D1.amazonaws.com
- https://stackoverflow.com/questions/45211594/running-a-custom-script-using-entrypoint-in-docker-compose
- https://stackoverflow.com/questions/74390647/postgres-airflow-db-permission-denied-for-schema-public
- https://stackoverflow.com/questions/60138692/sqlalchemy-psycopg2-errors-insufficientprivilege-permission-denied-for-relation#comment130285399_69322902
- https://fastapi.tiangolo.com/advanced/events/#alternative-events-deprecated
- https://www.youtube.com/watch?v=3c-iBn73dDE
- https://www.youtube.com/watch?v=2X8B_X2c27Q