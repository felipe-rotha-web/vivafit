const nodemailer = require('nodemailer')

const getSmtpConfig = () => {
  const { SMTP_HOST, SMTP_PORT, SMTP_USER, SMTP_PASS, SMTP_FROM } = process.env
  const port = Number(SMTP_PORT)

  if (
    !SMTP_HOST ||
    !Number.isInteger(port) ||
    port <= 0 ||
    !SMTP_USER ||
    !SMTP_PASS ||
    !SMTP_FROM
  ) {
    return null
  }

  return {
    host: SMTP_HOST,
    port,
    secure: process.env.SMTP_SECURE === 'true',
    auth: { user: SMTP_USER, pass: SMTP_PASS },
    from: SMTP_FROM,
  }
}

const isConfigured = () => getSmtpConfig() !== null

const sendPasswordResetCode = async (email, code) => {
  const config = getSmtpConfig()
  if (!config) {
    throw new Error('Configuração SMTP incompleta.')
  }

  const transporter = nodemailer.createTransport({
    host: config.host,
    port: config.port,
    secure: config.secure,
    auth: {
      user: config.auth.user,
      pass: config.auth.pass,
    },
  })

  await transporter.sendMail({
    from: config.from,
    to: email,
    subject: 'Código para redefinição de senha - VivaFit',
    text: `Seu código para redefinir a senha é ${code}. Ele expira em 10 minutos. Se você não solicitou esta alteração, ignore este email.`,
  })
}

module.exports = { isConfigured, sendPasswordResetCode }
