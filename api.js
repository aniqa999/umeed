const BASE_URL = import.meta.env.VITE_API_BASE_URL;

function authHeaders(token) {
  return {
    "Content-Type": "application/json",
    Authorization: `Bearer ${token}`,
  };
}

async function request(path, token, options = {}) {
  const res = await fetch(`${BASE_URL}${path}`, {
    ...options,
    headers: { ...authHeaders(token), ...(options.headers ?? {}) },
  });
  const data = await res.json().catch(() => ({}));
  if (!res.ok) {
    throw new Error(data.message || data.error || `Server error ${res.status}`);
  }
  return data;
}

// ── Admin Stats ───────────────────────────────────────────────────────────────
export const getStats = (token) => request("/api/admin/stats", token);

// ── User Management ───────────────────────────────────────────────────────────
export const getUsers = (token, params = {}) => {
  const qs = new URLSearchParams(
    Object.fromEntries(Object.entries(params).filter(([, v]) => v != null && v !== ""))
  ).toString();
  return request(`/api/admin/users${qs ? `?${qs}` : ""}`, token);
};

export const approveUser = (token, id, note) =>
  request(`/api/admin/users/${id}/approve`, token, {
    method: "PATCH",
    body: JSON.stringify({ note }),
  });

export const rejectUser = (token, id, note) =>
  request(`/api/admin/users/${id}/reject`, token, {
    method: "PATCH",
    body: JSON.stringify({ note }),
  });

export const suspendUser = (token, id, note) =>
  request(`/api/admin/users/${id}/suspend`, token, {
    method: "PATCH",
    body: JSON.stringify({ note }),
  });

export const reinstateUser = (token, id, note) =>
  request(`/api/admin/users/${id}/reinstate`, token, {
    method: "PATCH",
    body: JSON.stringify({ note }),
  });

// ── Activity Logs ─────────────────────────────────────────────────────────────
export const getLogs = (token, params = {}) => {
  const qs = new URLSearchParams(
    Object.fromEntries(Object.entries(params).filter(([, v]) => v != null && v !== ""))
  ).toString();
  return request(`/api/admin/logs${qs ? `?${qs}` : ""}`, token);
};

export const getUserLogs = (token, userId, params = {}) => {
  const qs = new URLSearchParams(
    Object.fromEntries(Object.entries(params).filter(([, v]) => v != null && v !== ""))
  ).toString();
  return request(`/api/admin/logs/user/${userId}${qs ? `?${qs}` : ""}`, token);
};

// ── Disasters ─────────────────────────────────────────────────────────────────
export const createDisaster = (token, body) =>
  request("/api/disasters", token, { method: "POST", body: JSON.stringify(body) });

export const predictAndSaveDisaster = (token, body) =>
  request("/api/disasters/predict-and-save", token, { method: "POST", body: JSON.stringify(body) });

export const updateDisaster = (token, id, body) =>
  request(`/api/disasters/${id}`, token, { method: "PATCH", body: JSON.stringify(body) });

export const deleteDisaster = (token, id) =>
  request(`/api/disasters/${id}`, token, { method: "DELETE" });

// ── Resources ─────────────────────────────────────────────────────────────────
export const getResources = (token, params = {}) => {
  const qs = new URLSearchParams(
    Object.fromEntries(Object.entries(params).filter(([, v]) => v != null && v !== ""))
  ).toString();
  return request(`/api/resources${qs ? `?${qs}` : ""}`, token);
};

export const getDisastersWithResources = (token, params = {}) => {
  const qs = new URLSearchParams(
    Object.fromEntries(Object.entries(params).filter(([, v]) => v != null && v !== ""))
  ).toString();
  return request(`/api/resources/disasters${qs ? `?${qs}` : ""}`, token);
};

export const getResourceByDisaster = (token, disasterId) =>
  request(`/api/resources/disaster/${disasterId}`, token);

export const deleteResourceByDisaster = (token, disasterId) =>
  request(`/api/resources/disaster/${disasterId}`, token, { method: "DELETE" });

// ── Reports ───────────────────────────────────────────────────────────────────
export const getReports = (token, params = {}) => {
  const qs = new URLSearchParams(
    Object.fromEntries(Object.entries(params).filter(([, v]) => v != null && v !== ""))
  ).toString();
  return request(`/api/reports${qs ? `?${qs}` : ""}`, token);
};

export const archiveReport = (token, id) =>
  request(`/api/reports/${id}/archive`, token, { method: "PATCH" });

export const deleteReport = (token, id) =>
  request(`/api/reports/${id}`, token, { method: "DELETE" });

// ── Predictions ───────────────────────────────────────────────────────────────
export const getPredictions = (token, params = {}) => {
  const qs = new URLSearchParams(
    Object.fromEntries(Object.entries(params).filter(([, v]) => v != null && v !== ""))
  ).toString();
  return request(`/api/admin/disasters${qs ? `?${qs}` : ""}`, token);
};