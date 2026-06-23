import mongoose from "mongoose";
import bcrypt from "bcryptjs";

const userSchema = new mongoose.Schema(
  {
    profileImage: {
      type: String,
      default: null,
    },

    fullName: {
      type: String,
      required: true,
      trim: true,
    },

    email: {
      type: String,
      required: true,
      unique: true,
      lowercase: true,
      trim: true,
    },

    password: {
      type: String,
      required: true,
      minlength: 8,
      select: false,
    },

    phone: {
      type: String,
      required: true,
      trim: true,
    },

    role: {
      type: String,
      enum: ["admin", "ngo", "government"],
      required: true,
    },

    organization: {
      type: String,
      required: true,
      trim: true,
    },

    designation: {
      type: String,
      trim: true,
    },

    department: {
      type: String,
      trim: true,
    },

    websiteLink: {
      type: String,
      trim: true,
    },

    experience: {
      type: String,
      trim: true,
    },

    cnic: {
      type: String,
      trim: true,
    },

    country: {
      type: String,
      trim: true,
      default: "Pakistan",
    },

    province: {
      type: String,
      enum: [
        "Punjab",
        "Sindh",
        "KPK",
        "Balochistan",
        "Gilgit-Baltistan",
        "Azad Kashmir",
      ],
      default: null,
      required: true,
    },

    district: {
      type: String,
      trim: true,
    },

    city: {
      type: String,
      trim: true,
    },

    area: {
      type: String,
      trim: true,
    },

    currentAddress: {
      type: String,
      trim: true,
    },

    status: {
      type: String,
      enum: ["pending", "approved", "rejected", "suspended"],
      default: function () {
        return this.role === "admin" ? "approved" : "pending";
      },
    },

    reviewedBy: {
      type: mongoose.Schema.Types.ObjectId,
      ref: "User",
      default: null,
    },

    reviewedAt: {
      type: Date,
      default: null,
    },

    reviewNote: {
      type: String,
      trim: true,
      default: null,
    },

    lastLogin: {
      type: Date,
      default: null,
    },

    passwordChangedAt: {
      type: Date,
      default: null,
    },

    resetPasswordToken: {
      type: String,
      select: false,
    },

    resetPasswordExpires: {
      type: Date,
      select: false,
    },

    isEmailVerified: {
      type: Boolean,
      default: false,
    },
  },
  {
    timestamps: true,
  },
);

userSchema.index({ role: 1 });
userSchema.index({ status: 1 });
userSchema.index({ organization: 1 });

userSchema.pre("save", async function () {
  if (!this.isModified("password")) return;
  const salt = await bcrypt.genSalt(12);
  this.password = await bcrypt.hash(this.password, salt);
  if (!this.isNew) this.passwordChangedAt = new Date();
});

userSchema.methods.comparePassword = async function (candidatePassword) {
  return bcrypt.compare(candidatePassword, this.password);
};

userSchema.methods.canLogin = function () {
  return this.status === "approved";
};

userSchema.methods.toPublicJSON = function () {
  return {
    _id: this._id,
    fullName: this.fullName,
    email: this.email,
    role: this.role,
    organization: this.organization,
    designation: this.designation,
    department: this.department,
    websiteLink: this.websiteLink,
    experience: this.experience,
    cnic: this.cnic,
    phone: this.phone,
    country: this.country,
    province: this.province,
    district: this.district,
    city: this.city,
    area: this.area,
    currentAddress: this.currentAddress,
    profileImage: this.profileImage,
    status: this.status,
    isEmailVerified: this.isEmailVerified,
    lastLogin: this.lastLogin,
    createdAt: this.createdAt,
  };
};

const User = mongoose.model("User", userSchema);

export default User;
