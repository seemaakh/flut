const mongoose = require("mongoose");

let mongoServer;

const connectDB = async () => {
  try {
    if (process.env.USE_IN_MEMORY_DB === "true") {
      const { MongoMemoryServer } = require("mongodb-memory-server");
      mongoServer = await MongoMemoryServer.create();
      const uri = mongoServer.getUri();
      const conn = await mongoose.connect(uri);
      console.log(
        `MongoDB connected to : ${conn.connection.host}`.yellow.underline.bold
      );
      return;
    }

    const conn = await mongoose.connect(process.env.LOCAL_DATABASE_URI);
    console.log(
      `MongoDB connected to : ${conn.connection.host}`.yellow.underline.bold
    );
  } catch (error) {
    console.error(`MongoDB connection error: ${error}`.red.underline.bold);
    process.exit(1); // Exit process on DB connection failure
  }
};

module.exports = connectDB;
