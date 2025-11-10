#include <gtk/gtk.h>
#include <stdlib.h>

void launch_app(GtkWidget *widget, gpointer data) {
    char cmd[256];
    snprintf(cmd, sizeof(cmd), "%s &", (char *)data);
    system(cmd);
}

int main(int argc, char *argv[]) {
    gtk_init(&argc, &argv);
    
    GtkWidget *window = gtk_window_new(GTK_WINDOW_TOPLEVEL);
    gtk_window_set_title(GTK_WINDOW(window), "BlazeNeuro");
    gtk_window_set_default_size(GTK_WINDOW(window), 600, 400);
    
    GtkWidget *grid = gtk_grid_new();
    gtk_grid_set_row_spacing(GTK_GRID(grid), 10);
    gtk_grid_set_column_spacing(GTK_GRID(grid), 10);
    gtk_container_add(GTK_CONTAINER(window), grid);
    
    char *apps[][2] = {
        {"Terminal", "xterm"},
        {"Files", "xterm -e ls"},
        {"Editor", "vi"},
        {"System", "top"}
    };
    
    for (int i = 0; i < 4; i++) {
        GtkWidget *btn = gtk_button_new_with_label(apps[i][0]);
        gtk_widget_set_size_request(btn, 150, 100);
        g_signal_connect(btn, "clicked", G_CALLBACK(launch_app), apps[i][1]);
        gtk_grid_attach(GTK_GRID(grid), btn, i % 2, i / 2, 1, 1);
    }
    
    g_signal_connect(window, "destroy", G_CALLBACK(gtk_main_quit), NULL);
    gtk_widget_show_all(window);
    gtk_main();
    
    return 0;
}
