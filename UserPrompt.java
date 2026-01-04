
import java.io.File;
import javax.swing.*;

class User {
  
  public static String prompt(String message) {
    return prompt(message, "");
  }

  public static String prompt(String message, String defaultValue) {

    final String[] result = new String[1];

    try {
      SwingUtilities.invokeAndWait(() -> {

        JTextField tf = new JTextField(20);
        tf.setText(defaultValue);

        JOptionPane pane = new JOptionPane(
          tf,
          JOptionPane.QUESTION_MESSAGE,
          JOptionPane.OK_CANCEL_OPTION
        );

        JDialog dialog = pane.createDialog(message);
        dialog.setAlwaysOnTop(true);

        // Ensures typing focus always works even under NEWT/P3D/macOS
        dialog.addWindowFocusListener(new java.awt.event.WindowFocusListener() {
          @Override
          public void windowGainedFocus(java.awt.event.WindowEvent e) {
            tf.requestFocusInWindow();
            tf.selectAll();
          }
          @Override
          public void windowLostFocus(java.awt.event.WindowEvent e) {}
        });

        dialog.setVisible(true);  // blocks until closed or OK/Cancel

        Object choice = pane.getValue();
        if (choice instanceof Integer && ((Integer) choice) == JOptionPane.OK_OPTION) {
          result[0] = tf.getText();
        } else {
          result[0] = null;
        }
      });
    }

    catch (Exception e) {
      e.printStackTrace();
      return null;
    }

    return result[0];
  }
  
  public static File promptSaveFolder(File patchesRoot) {
    JFileChooser fc = new JFileChooser(patchesRoot);
    fc.setDialogTitle("Choose patch category folder");
    fc.setFileSelectionMode(JFileChooser.DIRECTORIES_ONLY);
    fc.setAcceptAllFileFilterUsed(false);

    int res = fc.showOpenDialog(null);
    if (res != JFileChooser.APPROVE_OPTION) return null;

    File chosen = fc.getSelectedFile();

    // Optional safety: enforce that chosen is inside patchesRoot
    try {
      File root = patchesRoot.getCanonicalFile();
      File sel  = chosen.getCanonicalFile();
      if (!sel.getPath().startsWith(root.getPath())) {
        JOptionPane.showMessageDialog(null,
            "Please choose a folder inside:\n" + root.getPath(),
            "Invalid folder",
            JOptionPane.ERROR_MESSAGE);
        return null;
      }
    } catch (Exception ignored) {}

    return chosen;
  }

  public static File promptSaveProjectDir(File patchesRoot, String defaultName) {
    File folder = promptSaveFolder(patchesRoot);
    if (folder == null) return null;

    String name = JOptionPane.showInputDialog(null, "Project name:", defaultName);
    if (name == null) return null;
    name = name.trim();
    if (name.isEmpty()) return null;

    return new File(folder, name); // final folder where you save
  }

}
