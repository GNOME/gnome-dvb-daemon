/*
 * Generated by gdbus-codegen 2.42.0. DO NOT EDIT.
 *
 * The license of this code is the same as for the source it was derived from.
 */

#ifndef __GDD_CHANNEL_LIST_H__
#define __GDD_CHANNEL_LIST_H__

#include <gio/gio.h>

G_BEGIN_DECLS


/* ------------------------------------------------------------------------ */
/* Declarations for org.gnome.DVB.ChannelList */

#define GDD_CHANNEL_LIST_TYPE_ (gdd_channel_list__get_type ())
#define GDD_CHANNEL_LIST_(o) (G_TYPE_CHECK_INSTANCE_CAST ((o), GDD_CHANNEL_LIST_TYPE_, GddChannelList))
#define GDD_CHANNEL_LIST_IS_(o) (G_TYPE_CHECK_INSTANCE_TYPE ((o), GDD_CHANNEL_LIST_TYPE_))
#define GDD_CHANNEL_LIST__GET_IFACE(o) (G_TYPE_INSTANCE_GET_INTERFACE ((o), GDD_CHANNEL_LIST_TYPE_, GddChannelListIface))

struct _GddChannelList;
typedef struct _GddChannelList GddChannelList;
typedef struct _GddChannelListIface GddChannelListIface;

struct _GddChannelListIface
{
  GTypeInterface parent_iface;


  gboolean (*handle_add_channel_to_group) (
    GddChannelList *object,
    GDBusMethodInvocation *invocation,
    guint arg_channel_id,
    gint arg_channel_group_id);

  gboolean (*handle_get_channel_infos) (
    GddChannelList *object,
    GDBusMethodInvocation *invocation);

  gboolean (*handle_get_channel_name) (
    GddChannelList *object,
    GDBusMethodInvocation *invocation,
    guint arg_channel_id);

  gboolean (*handle_get_channel_network) (
    GddChannelList *object,
    GDBusMethodInvocation *invocation,
    guint arg_channel_id);

  gboolean (*handle_get_channel_url) (
    GddChannelList *object,
    GDBusMethodInvocation *invocation,
    guint arg_channel_id);

  gboolean (*handle_get_channels) (
    GddChannelList *object,
    GDBusMethodInvocation *invocation);

  gboolean (*handle_get_channels_of_group) (
    GddChannelList *object,
    GDBusMethodInvocation *invocation,
    gint arg_channel_group_id);

  gboolean (*handle_get_radio_channels) (
    GddChannelList *object,
    GDBusMethodInvocation *invocation);

  gboolean (*handle_get_tvchannels) (
    GddChannelList *object,
    GDBusMethodInvocation *invocation);

  gboolean (*handle_is_radio_channel) (
    GddChannelList *object,
    GDBusMethodInvocation *invocation,
    guint arg_channel_id);

  gboolean (*handle_remove_channel_from_group) (
    GddChannelList *object,
    GDBusMethodInvocation *invocation,
    guint arg_channel_id,
    gint arg_channel_group_id);

  void (*changed) (
    GddChannelList *object,
    guint arg_channel_id,
    guint arg_type);

};

GType gdd_channel_list__get_type (void) G_GNUC_CONST;

GDBusInterfaceInfo *gdd_channel_list__interface_info (void);
guint gdd_channel_list__override_properties (GObjectClass *klass, guint property_id_begin);


/* D-Bus method call completion functions: */
void gdd_channel_list__complete_get_channels (
    GddChannelList *object,
    GDBusMethodInvocation *invocation,
    GVariant *result);

void gdd_channel_list__complete_get_radio_channels (
    GddChannelList *object,
    GDBusMethodInvocation *invocation,
    GVariant *result);

void gdd_channel_list__complete_get_tvchannels (
    GddChannelList *object,
    GDBusMethodInvocation *invocation,
    GVariant *result);

void gdd_channel_list__complete_get_channel_name (
    GddChannelList *object,
    GDBusMethodInvocation *invocation,
    const gchar *channel_name,
    gboolean result);

void gdd_channel_list__complete_get_channel_network (
    GddChannelList *object,
    GDBusMethodInvocation *invocation,
    const gchar *network,
    gboolean result);

void gdd_channel_list__complete_is_radio_channel (
    GddChannelList *object,
    GDBusMethodInvocation *invocation,
    gboolean radio,
    gboolean result);

void gdd_channel_list__complete_get_channel_url (
    GddChannelList *object,
    GDBusMethodInvocation *invocation,
    const gchar *url,
    gboolean result);

void gdd_channel_list__complete_get_channel_infos (
    GddChannelList *object,
    GDBusMethodInvocation *invocation,
    GVariant *result);

void gdd_channel_list__complete_get_channels_of_group (
    GddChannelList *object,
    GDBusMethodInvocation *invocation,
    GVariant *channel_ids,
    gboolean result);

void gdd_channel_list__complete_add_channel_to_group (
    GddChannelList *object,
    GDBusMethodInvocation *invocation,
    gboolean result);

void gdd_channel_list__complete_remove_channel_from_group (
    GddChannelList *object,
    GDBusMethodInvocation *invocation,
    gboolean result);



/* D-Bus signal emissions functions: */
void gdd_channel_list__emit_changed (
    GddChannelList *object,
    guint arg_channel_id,
    guint arg_type);



/* D-Bus method calls: */
void gdd_channel_list__call_get_channels (
    GddChannelList *proxy,
    GCancellable *cancellable,
    GAsyncReadyCallback callback,
    gpointer user_data);

gboolean gdd_channel_list__call_get_channels_finish (
    GddChannelList *proxy,
    GVariant **out_result,
    GAsyncResult *res,
    GError **error);

gboolean gdd_channel_list__call_get_channels_sync (
    GddChannelList *proxy,
    GVariant **out_result,
    GCancellable *cancellable,
    GError **error);

void gdd_channel_list__call_get_radio_channels (
    GddChannelList *proxy,
    GCancellable *cancellable,
    GAsyncReadyCallback callback,
    gpointer user_data);

gboolean gdd_channel_list__call_get_radio_channels_finish (
    GddChannelList *proxy,
    GVariant **out_result,
    GAsyncResult *res,
    GError **error);

gboolean gdd_channel_list__call_get_radio_channels_sync (
    GddChannelList *proxy,
    GVariant **out_result,
    GCancellable *cancellable,
    GError **error);

void gdd_channel_list__call_get_tvchannels (
    GddChannelList *proxy,
    GCancellable *cancellable,
    GAsyncReadyCallback callback,
    gpointer user_data);

gboolean gdd_channel_list__call_get_tvchannels_finish (
    GddChannelList *proxy,
    GVariant **out_result,
    GAsyncResult *res,
    GError **error);

gboolean gdd_channel_list__call_get_tvchannels_sync (
    GddChannelList *proxy,
    GVariant **out_result,
    GCancellable *cancellable,
    GError **error);

void gdd_channel_list__call_get_channel_name (
    GddChannelList *proxy,
    guint arg_channel_id,
    GCancellable *cancellable,
    GAsyncReadyCallback callback,
    gpointer user_data);

gboolean gdd_channel_list__call_get_channel_name_finish (
    GddChannelList *proxy,
    gchar **out_channel_name,
    gboolean *out_result,
    GAsyncResult *res,
    GError **error);

gboolean gdd_channel_list__call_get_channel_name_sync (
    GddChannelList *proxy,
    guint arg_channel_id,
    gchar **out_channel_name,
    gboolean *out_result,
    GCancellable *cancellable,
    GError **error);

void gdd_channel_list__call_get_channel_network (
    GddChannelList *proxy,
    guint arg_channel_id,
    GCancellable *cancellable,
    GAsyncReadyCallback callback,
    gpointer user_data);

gboolean gdd_channel_list__call_get_channel_network_finish (
    GddChannelList *proxy,
    gchar **out_network,
    gboolean *out_result,
    GAsyncResult *res,
    GError **error);

gboolean gdd_channel_list__call_get_channel_network_sync (
    GddChannelList *proxy,
    guint arg_channel_id,
    gchar **out_network,
    gboolean *out_result,
    GCancellable *cancellable,
    GError **error);

void gdd_channel_list__call_is_radio_channel (
    GddChannelList *proxy,
    guint arg_channel_id,
    GCancellable *cancellable,
    GAsyncReadyCallback callback,
    gpointer user_data);

gboolean gdd_channel_list__call_is_radio_channel_finish (
    GddChannelList *proxy,
    gboolean *out_radio,
    gboolean *out_result,
    GAsyncResult *res,
    GError **error);

gboolean gdd_channel_list__call_is_radio_channel_sync (
    GddChannelList *proxy,
    guint arg_channel_id,
    gboolean *out_radio,
    gboolean *out_result,
    GCancellable *cancellable,
    GError **error);

void gdd_channel_list__call_get_channel_url (
    GddChannelList *proxy,
    guint arg_channel_id,
    GCancellable *cancellable,
    GAsyncReadyCallback callback,
    gpointer user_data);

gboolean gdd_channel_list__call_get_channel_url_finish (
    GddChannelList *proxy,
    gchar **out_url,
    gboolean *out_result,
    GAsyncResult *res,
    GError **error);

gboolean gdd_channel_list__call_get_channel_url_sync (
    GddChannelList *proxy,
    guint arg_channel_id,
    gchar **out_url,
    gboolean *out_result,
    GCancellable *cancellable,
    GError **error);

void gdd_channel_list__call_get_channel_infos (
    GddChannelList *proxy,
    GCancellable *cancellable,
    GAsyncReadyCallback callback,
    gpointer user_data);

gboolean gdd_channel_list__call_get_channel_infos_finish (
    GddChannelList *proxy,
    GVariant **out_result,
    GAsyncResult *res,
    GError **error);

gboolean gdd_channel_list__call_get_channel_infos_sync (
    GddChannelList *proxy,
    GVariant **out_result,
    GCancellable *cancellable,
    GError **error);

void gdd_channel_list__call_get_channels_of_group (
    GddChannelList *proxy,
    gint arg_channel_group_id,
    GCancellable *cancellable,
    GAsyncReadyCallback callback,
    gpointer user_data);

gboolean gdd_channel_list__call_get_channels_of_group_finish (
    GddChannelList *proxy,
    GVariant **out_channel_ids,
    gboolean *out_result,
    GAsyncResult *res,
    GError **error);

gboolean gdd_channel_list__call_get_channels_of_group_sync (
    GddChannelList *proxy,
    gint arg_channel_group_id,
    GVariant **out_channel_ids,
    gboolean *out_result,
    GCancellable *cancellable,
    GError **error);

void gdd_channel_list__call_add_channel_to_group (
    GddChannelList *proxy,
    guint arg_channel_id,
    gint arg_channel_group_id,
    GCancellable *cancellable,
    GAsyncReadyCallback callback,
    gpointer user_data);

gboolean gdd_channel_list__call_add_channel_to_group_finish (
    GddChannelList *proxy,
    gboolean *out_result,
    GAsyncResult *res,
    GError **error);

gboolean gdd_channel_list__call_add_channel_to_group_sync (
    GddChannelList *proxy,
    guint arg_channel_id,
    gint arg_channel_group_id,
    gboolean *out_result,
    GCancellable *cancellable,
    GError **error);

void gdd_channel_list__call_remove_channel_from_group (
    GddChannelList *proxy,
    guint arg_channel_id,
    gint arg_channel_group_id,
    GCancellable *cancellable,
    GAsyncReadyCallback callback,
    gpointer user_data);

gboolean gdd_channel_list__call_remove_channel_from_group_finish (
    GddChannelList *proxy,
    gboolean *out_result,
    GAsyncResult *res,
    GError **error);

gboolean gdd_channel_list__call_remove_channel_from_group_sync (
    GddChannelList *proxy,
    guint arg_channel_id,
    gint arg_channel_group_id,
    gboolean *out_result,
    GCancellable *cancellable,
    GError **error);



/* ---- */

#define GDD_CHANNEL_LIST_TYPE__PROXY (gdd_channel_list__proxy_get_type ())
#define GDD_CHANNEL_LIST__PROXY(o) (G_TYPE_CHECK_INSTANCE_CAST ((o), GDD_CHANNEL_LIST_TYPE__PROXY, GddChannelListProxy))
#define GDD_CHANNEL_LIST__PROXY_CLASS(k) (G_TYPE_CHECK_CLASS_CAST ((k), GDD_CHANNEL_LIST_TYPE__PROXY, GddChannelListProxyClass))
#define GDD_CHANNEL_LIST__PROXY_GET_CLASS(o) (G_TYPE_INSTANCE_GET_CLASS ((o), GDD_CHANNEL_LIST_TYPE__PROXY, GddChannelListProxyClass))
#define GDD_CHANNEL_LIST_IS__PROXY(o) (G_TYPE_CHECK_INSTANCE_TYPE ((o), GDD_CHANNEL_LIST_TYPE__PROXY))
#define GDD_CHANNEL_LIST_IS__PROXY_CLASS(k) (G_TYPE_CHECK_CLASS_TYPE ((k), GDD_CHANNEL_LIST_TYPE__PROXY))

typedef struct _GddChannelListProxy GddChannelListProxy;
typedef struct _GddChannelListProxyClass GddChannelListProxyClass;
typedef struct _GddChannelListProxyPrivate GddChannelListProxyPrivate;

struct _GddChannelListProxy
{
  /*< private >*/
  GDBusProxy parent_instance;
  GddChannelListProxyPrivate *priv;
};

struct _GddChannelListProxyClass
{
  GDBusProxyClass parent_class;
};

GType gdd_channel_list__proxy_get_type (void) G_GNUC_CONST;

void gdd_channel_list__proxy_new (
    GDBusConnection     *connection,
    GDBusProxyFlags      flags,
    const gchar         *name,
    const gchar         *object_path,
    GCancellable        *cancellable,
    GAsyncReadyCallback  callback,
    gpointer             user_data);
GddChannelList *gdd_channel_list__proxy_new_finish (
    GAsyncResult        *res,
    GError             **error);
GddChannelList *gdd_channel_list__proxy_new_sync (
    GDBusConnection     *connection,
    GDBusProxyFlags      flags,
    const gchar         *name,
    const gchar         *object_path,
    GCancellable        *cancellable,
    GError             **error);

void gdd_channel_list__proxy_new_for_bus (
    GBusType             bus_type,
    GDBusProxyFlags      flags,
    const gchar         *name,
    const gchar         *object_path,
    GCancellable        *cancellable,
    GAsyncReadyCallback  callback,
    gpointer             user_data);
GddChannelList *gdd_channel_list__proxy_new_for_bus_finish (
    GAsyncResult        *res,
    GError             **error);
GddChannelList *gdd_channel_list__proxy_new_for_bus_sync (
    GBusType             bus_type,
    GDBusProxyFlags      flags,
    const gchar         *name,
    const gchar         *object_path,
    GCancellable        *cancellable,
    GError             **error);


/* ---- */

#define GDD_CHANNEL_LIST_TYPE__SKELETON (gdd_channel_list__skeleton_get_type ())
#define GDD_CHANNEL_LIST__SKELETON(o) (G_TYPE_CHECK_INSTANCE_CAST ((o), GDD_CHANNEL_LIST_TYPE__SKELETON, GddChannelListSkeleton))
#define GDD_CHANNEL_LIST__SKELETON_CLASS(k) (G_TYPE_CHECK_CLASS_CAST ((k), GDD_CHANNEL_LIST_TYPE__SKELETON, GddChannelListSkeletonClass))
#define GDD_CHANNEL_LIST__SKELETON_GET_CLASS(o) (G_TYPE_INSTANCE_GET_CLASS ((o), GDD_CHANNEL_LIST_TYPE__SKELETON, GddChannelListSkeletonClass))
#define GDD_CHANNEL_LIST_IS__SKELETON(o) (G_TYPE_CHECK_INSTANCE_TYPE ((o), GDD_CHANNEL_LIST_TYPE__SKELETON))
#define GDD_CHANNEL_LIST_IS__SKELETON_CLASS(k) (G_TYPE_CHECK_CLASS_TYPE ((k), GDD_CHANNEL_LIST_TYPE__SKELETON))

typedef struct _GddChannelListSkeleton GddChannelListSkeleton;
typedef struct _GddChannelListSkeletonClass GddChannelListSkeletonClass;
typedef struct _GddChannelListSkeletonPrivate GddChannelListSkeletonPrivate;

struct _GddChannelListSkeleton
{
  /*< private >*/
  GDBusInterfaceSkeleton parent_instance;
  GddChannelListSkeletonPrivate *priv;
};

struct _GddChannelListSkeletonClass
{
  GDBusInterfaceSkeletonClass parent_class;
};

GType gdd_channel_list__skeleton_get_type (void) G_GNUC_CONST;

GddChannelList *gdd_channel_list__skeleton_new (void);


G_END_DECLS

#endif /* __GDD_CHANNEL_LIST_H__ */
