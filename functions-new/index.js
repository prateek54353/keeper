const functions = require('firebase-functions');
const admin = require('firebase-admin');
const nodemailer = require('nodemailer');

admin.initializeApp();

// Configure nodemailer with your email service (e.g., Gmail)
const transporter = nodemailer.createTransport({
  service: 'gmail',
  auth: {
    user: functions.config().email.user,
    pass: functions.config().email.password,
  },
});

exports.sendOTPEmail = functions.firestore
  .document('otps/{email}')
  .onCreate(async (snap, context) => {
    const data = snap.data();
    const email = context.params.email;
    const otp = data.otp;

    const mailOptions = {
      from: functions.config().email.user,
      to: email,
      subject: 'Your OTP for Keeper App',
      html: `
        <h2>Welcome to Keeper!</h2>
        <p>Your OTP for email verification is: <strong>${otp}</strong></p>
        <p>This OTP will expire in 10 minutes.</p>
        <p>If you didn't request this OTP, please ignore this email.</p>
      `,
    };

    try {
      await transporter.sendMail(mailOptions);
      console.log('OTP email sent successfully');
      return null;
    } catch (error) {
      console.error('Error sending OTP email:', error);
      throw new functions.https.HttpsError('internal', 'Error sending OTP email');
    }
  });

// Clean up expired OTPs
exports.cleanupExpiredOTPs = functions.pubsub
  .schedule('every 15 minutes')
  .onRun(async (context) => {
    const otpsRef = admin.firestore().collection('otps');
    const tenMinutesAgo = admin.firestore.Timestamp.fromDate(
      new Date(Date.now() - 10 * 60 * 1000)
    );

    const expiredOTPs = await otpsRef
      .where('createdAt', '<=', tenMinutesAgo)
      .get();

    const batch = admin.firestore().batch();
    expiredOTPs.forEach((doc) => {
      batch.delete(doc.ref);
    });

    await batch.commit();
    console.log(`Cleaned up ${expiredOTPs.size} expired OTPs`);
    return null;
  }); 