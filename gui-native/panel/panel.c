#include <gtk/gtk.h>
#include <time.h>

GtkWidget *time_label;

gboolean update_time(gpointer data) {
    time_t now = time(NULL);
    struct tm *t = localtime(&now);
    char time_str[64];
    strftime(time_str, sizeof(time_str), "%H:%M:%S", t);
    gtk_label_set_text(GTK_LABEL(time_label), time_str);
    return TRUE;
}

void launch_terminal(GtkWidget *widget, gpointer data) {
    system("xterm &");
}

int main(int argc, char *argv[]) {
    gtk_init(&argc, &argv);
    
    GtkWidget *window = gtk_window_new(GTK_WINDOW_TOPLEVEL);
    gtk_window_set_default_size(GTK_WINDOW(window), 1920, 40);
    gtk_window_set_decorated(GTK_WINDOW(window), FALSE);
    
    GtkWidget *box = gtk_box_new(GTK_ORIENTATION_HORIZONTAL, 10);
    gtk_container_add(GTK_CONTAINER(window), box);
    
    GtkWidget *logo = gtk_label_new("⚡ BLAZENEURO");
    gtk_box_pack_start(GTK_BOX(box), logo, FALSE, FALSE, 10);
    
    GtkWidget *btn = gtk_button_new_with_label("Terminal");
    g_signal_connect(btn, "clicked", G_CALLBACK(launch_terminal), NULL);
    gtk_box_pack_start(GTK_BOX(box), btn, FALSE, FALSE, 5);
    
    time_label = gtk_label_new("00:00:00");
    gtk_box_pack_end(GTK_BOX(box), time_label, FALSE, FALSE, 10);
    
    g_timeout_add(1000, update_time, NULL);
    
    gtk_widget_show_all(window);
    gtk_main();
    
    return 0;
}
