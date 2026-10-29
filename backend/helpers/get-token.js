const getToken = (req) => {
  const authHeader = req.headers.authorization;
  if (!authHeader || typeof authHeader !== 'string') {
    return null;
  }

  const parts = authHeader.split(' ');
  const token = parts.length > 1 ? parts.slice(1).join(' ').trim() : authHeader.trim();
  return token && token.length > 0 ? token : null;
};

module.exports = getToken;