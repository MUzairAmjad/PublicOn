package com.uzair.publicon.util;

import java.util.Properties;
import jakarta.mail.*;
import jakarta.mail.internet.*;

public class EmailUtility {
    public static void sendOTPEmail(String recipientEmail, String otp) {
        String senderEmail = "spikyflame25@gmail.com";
        String senderPassword = "kkdz svst kecj rjlc"; 

        Properties props = new Properties();
        props.put("mail.smtp.host", "smtp.gmail.com");
        props.put("mail.smtp.port", "587");
        props.put("mail.smtp.auth", "true");
        props.put("mail.smtp.starttls.enable", "true");

        Session session = Session.getInstance(props, new Authenticator() {
            protected PasswordAuthentication getPasswordAuthentication() {
                return new PasswordAuthentication(senderEmail, senderPassword);
            }
        });

        try {
            Message message = new MimeMessage(session);
            message.setFrom(new InternetAddress(senderEmail));
            message.setRecipients(Message.RecipientType.TO, InternetAddress.parse(recipientEmail));
            message.setSubject("Your PublicOn Verification Code");
            message.setText("Your 6-digit verification code is: " + otp);

            Transport.send(message);
        } catch (MessagingException e) {
            e.printStackTrace();
        }
    }
}