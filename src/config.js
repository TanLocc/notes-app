import { config } from "dotenv";
config();

export const database = {
  connectionLimit: 10,
  host: process.env.DATABASE_HOST || "mysql-production",
  user: process.env.DATABASE_USER || "nam",
  password: process.env.DATABASE_PASSWORD || "password",
  database: process.env.DATABASE_NAME || "dblinks",
};

export const port = process.env.PORT || 4000;
