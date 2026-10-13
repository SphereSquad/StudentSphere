
package com.studentsphere.profile;

import java.io.File;
import java.io.IOException;
import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.Paths;
import java.util.Locale;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.MultipartConfig;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import jakarta.servlet.http.Part;

@WebServlet("/profile-photo")
@MultipartConfig(
    fileSizeThreshold = 1024 * 1024,
    maxFileSize = 2 * 1024 * 1024,
    maxRequestSize = 3 * 1024 * 1024
)
public class ProfilePhotoServlet extends HttpServlet {

    private static final long serialVersionUID = 1L;

    @Override
    protected void doPost(HttpServletRequest request,
                          HttpServletResponse response)
            throws ServletException, IOException {

        String contextPath = request.getContextPath();
        HttpSession session = request.getSession(false);

        if (session == null || session.getAttribute("userId") == null) {
            response.sendRedirect(contextPath + "/login.jsp");
            return;
        }

        int userId;

        try {
            userId = Integer.parseInt(
                session.getAttribute("userId").toString()
            );
        } catch (NumberFormatException e) {
            response.sendError(
                HttpServletResponse.SC_BAD_REQUEST,
                "Invalid user session."
            );
            return;
        }

        String action = request.getParameter("action");

        String uploadDirectory = getServletContext().getRealPath("/uploads");

        if (uploadDirectory == null) {
            throw new ServletException(
                "Upload directory is unavailable. Check Tomcat deployment settings."
            );
        }

        File directory = new File(uploadDirectory);

        if (!directory.exists() && !directory.mkdirs()) {
            throw new ServletException(
                "Unable to create the uploads directory."
            );
        }

        String oldPhoto = (String) session.getAttribute("profilePhoto");

        // REMOVE PROFILE PHOTO
        if ("remove".equals(action)) {

            if (oldPhoto != null && !oldPhoto.trim().isEmpty()) {
                String oldFileName = Paths.get(oldPhoto)
                    .getFileName().toString();

                File oldFile = new File(directory, oldFileName);

                if (oldFile.isFile()) {
                    oldFile.delete();
                }
            }

            session.removeAttribute("profilePhoto");

            response.sendRedirect(
                contextPath + "/modules/profile/profile.jsp?photoRemoved=1"
            );
            return;
        }

        // UPLOAD PROFILE PHOTO
        if (!"upload".equals(action)) {
            response.sendError(
                HttpServletResponse.SC_BAD_REQUEST,
                "Invalid photo action."
            );
            return;
        }

        Part photoPart;

        try {
            photoPart = request.getPart("photo");
        } catch (IllegalStateException e) {
            response.sendRedirect(
                contextPath + "/modules/profile/profile.jsp?photoError=size"
            );
            return;
        }

        if (photoPart == null || photoPart.getSize() == 0) {
            response.sendRedirect(
                contextPath + "/modules/profile/profile.jsp?photoError=empty"
            );
            return;
        }

        if (photoPart.getSize() > 2 * 1024 * 1024) {
            response.sendRedirect(
                contextPath + "/modules/profile/profile.jsp?photoError=size"
            );
            return;
        }

        String contentType = photoPart.getContentType();

        String extension;

        if ("image/jpeg".equalsIgnoreCase(contentType)) {
            extension = ".jpg";
        } else if ("image/png".equalsIgnoreCase(contentType)) {
            extension = ".png";
        } else {
            response.sendRedirect(
                contextPath + "/modules/profile/profile.jsp?photoError=type"
            );
            return;
        }

        String fileName = "profile_" + userId + extension;
        Path destination = Paths.get(uploadDirectory, fileName);

        try {
            // Replace the previous image for this user.
            photoPart.write(destination.toString());

            // Remove the old file if its extension has changed.
            if (oldPhoto != null && !oldPhoto.trim().isEmpty()) {
                String oldFileName = Paths.get(oldPhoto)
                    .getFileName().toString();

                if (!oldFileName.equals(fileName)) {
                    Files.deleteIfExists(
                        Paths.get(uploadDirectory, oldFileName)
                    );
                }
            }

            // Store the relative path used by profile.jsp.
            session.setAttribute(
                "profilePhoto",
                "uploads/" + fileName
            );

            response.sendRedirect(
                contextPath + "/modules/profile/profile.jsp?photoUpdated=1"
            );

        } catch (IOException e) {
            getServletContext().log("Profile photo upload failed.", e);
            throw new ServletException(
                "Unable to save profile photo.", e
            );
        }
    }
}
