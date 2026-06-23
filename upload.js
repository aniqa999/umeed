import multer from "multer";
import path from "path";

const storage = multer.memoryStorage();

const fileFilter = (req, file, cb) => {
  const allowedTypes = /jpeg|jpg|png|gif|webp/;
  const extname = allowedTypes.test(
    path.extname(file.originalname).toLowerCase(),
  );

  const mimetype = file.mimetype;
  const isValidMimetype =
    mimetype === "image/jpeg" ||
    mimetype === "image/jpg" ||
    mimetype === "image/png" ||
    mimetype === "image/gif" ||
    mimetype === "image/webp" ||
    mimetype === "application/octet-stream";

  if (extname || isValidMimetype) {
    cb(null, true);
  } else {
    cb(
      new Error(
        `File type not allowed. Received: ${mimetype}, Extension: ${path.extname(file.originalname)}`,
      ),
      false,
    );
  }
};

const upload = multer({
  storage: storage,
  limits: {
    fileSize: 5 * 1024 * 1024,
  },
  fileFilter: fileFilter,
});

export default upload;
