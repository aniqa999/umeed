import userModel from "../models/userModel.js";

const deleteProfile = async (req, res) => {
  try {
    const user = await userModel.findById(req.user.id);

    if (!user) {
      return res.status(404).json({ message: "User not found" });
    }

    await userModel.findByIdAndDelete(req.user.id);

    res.clearCookie("refreshToken");
    res.status(200).json({ message: "Account deleted successfully" });
  } catch (error) {
    res.status(500).json({ message: "Server error during deletion" });
  }
};

const requestProfileUpdate = async (req, res) => {
  try {
    const { name, phone, position, organization, profilePic } = req.body;

    const updateData = {
      name,
      phone,
      position,
      organization,
      profilePic,
      requestedAt: new Date(),
    };

    const user = await userModel.findByIdAndUpdate(
      req.user.id,
      {
        pendingUpdate: updateData,
        updateRequestStatus: "pending",
      },
      { new: true },
    );

    res.status(200).json({
      message: "Update request sent to admin",
      status: user.updateRequestStatus,
    });
  } catch (error) {
    res.status(500).json({ message: "Failed to submit update request" });
  }
};

export { requestProfileUpdate, deleteProfile };
