import { MongoClient } from "mongodb";

const client = globalThis.__gymMongo || (globalThis.__gymMongo = new MongoClient(process.env.MONGODB_URI || "mongodb://localhost:27017"));

export async function biometrics() {
  await client.connect();
  return client.db("gym_nosql_db").collection("member_biometrics");
}
