const authorise = (...roles) => {
  return (req, res, next) => {    
    if (!roles.includes(req.user.role)) {
      return res.status(403).json({
        success: false,
        message: `Access denied. This route requires one of the following roles: ${roles.join(", ")}.`,
      });
    }
    next();
  };
};

export { authorise };
