/* gstreamer-mpegts-1.0.vapi generated by vapigen-0.24, do not modify. */

[CCode (cprefix = "GstMpegts", gir_namespace = "GstMpegts", gir_version = "1.0", lower_case_cprefix = "gst_mpegts_")]
namespace GstMpegts {
	[CCode (cheader_filename = "gst/mpegts/mpegts.h", copy_function = "g_boxed_copy", free_function = "g_boxed_free", type_id = "gst_mpegts_atsc_eit_get_type ()")]
	[Compact]
	public class AtscEIT {
		public weak GLib.GenericArray<GstMpegts.AtscEITEvent> events;
		public uint8 protocol_version;
		public uint16 source_id;
	}
	[CCode (cheader_filename = "gst/mpegts/mpegts.h", copy_function = "g_boxed_copy", free_function = "g_boxed_free", type_id = "gst_mpegts_atsc_eit_event_get_type ()")]
	[Compact]
	public class AtscEITEvent {
		public weak GLib.GenericArray<GstMpegts.Descriptor> descriptors;
		public uint8 etm_location;
		public uint16 event_id;
		public uint32 length_in_seconds;
		public uint32 start_time;
		public weak GLib.GenericArray<GstMpegts.AtscMultString> titles;
	}
	[CCode (cheader_filename = "gst/mpegts/mpegts.h", copy_function = "g_boxed_copy", free_function = "g_boxed_free", type_id = "gst_mpegts_atsc_ett_get_type ()")]
	[Compact]
	public class AtscETT {
		public uint32 etm_id;
		public uint16 ett_table_id_extension;
		public weak GLib.GenericArray<GstMpegts.AtscMultString> messages;
		public uint16 protocol_version;
	}
	[CCode (cheader_filename = "gst/mpegts/mpegts.h", copy_function = "g_boxed_copy", free_function = "g_boxed_free", type_id = "gst_mpegts_atsc_mgt_get_type ()")]
	[Compact]
	public class AtscMGT {
		public weak GLib.GenericArray<GstMpegts.Descriptor> descriptors;
		public uint8 protocol_version;
		public weak GLib.GenericArray<GstMpegts.AtscMGTTable> tables;
		public uint16 tables_defined;
	}
	[CCode (cheader_filename = "gst/mpegts/mpegts.h", copy_function = "g_boxed_copy", free_function = "g_boxed_free", type_id = "gst_mpegts_atsc_mgt_table_get_type ()")]
	[Compact]
	public class AtscMGTTable {
		public weak GLib.GenericArray<GstMpegts.Descriptor> descriptors;
		public uint32 number_bytes;
		public uint16 pid;
		public uint16 table_type;
		public uint8 version_number;
	}
	[CCode (cheader_filename = "gst/mpegts/mpegts.h", copy_function = "g_boxed_copy", free_function = "g_boxed_free", type_id = "gst_mpegts_atsc_mult_string_get_type ()")]
	[Compact]
	public class AtscMultString {
		[CCode (array_length = false, array_null_terminated = true)]
		public weak char[] iso_639_langcode;
		public weak GLib.GenericArray<GstMpegts.AtscStringSegment> segments;
	}
	[CCode (cheader_filename = "gst/mpegts/mpegts.h", copy_function = "g_boxed_copy", free_function = "g_boxed_free", type_id = "gst_mpegts_atsc_stt_get_type ()")]
	[Compact]
	public class AtscSTT {
		public weak GLib.GenericArray<GstMpegts.Descriptor> descriptors;
		public uint8 ds_dayofmonth;
		public uint8 ds_hour;
		public bool ds_status;
		public uint8 gps_utc_offset;
		public uint8 protocol_version;
		public uint32 system_time;
		public weak Gst.DateTime utc_datetime;
		public Gst.DateTime get_datetime_utc ();
	}
	[CCode (cheader_filename = "gst/mpegts/mpegts.h", copy_function = "g_boxed_copy", free_function = "g_boxed_free", type_id = "gst_mpegts_atsc_string_segment_get_type ()")]
	[Compact]
	public class AtscStringSegment {
		public weak string cached_string;
		public uint8 compressed_data;
		public uint8 compressed_data_size;
		public uint8 compression_type;
		public uint8 mode;
		public unowned string get_string ();
	}
	[CCode (cheader_filename = "gst/mpegts/mpegts.h", copy_function = "g_boxed_copy", free_function = "g_boxed_free", type_id = "gst_mpegts_atsc_vct_get_type ()")]
	[Compact]
	public class AtscVCT {
		public weak GLib.GenericArray<GstMpegts.Descriptor> descriptors;
		public uint8 protocol_version;
		public weak GLib.GenericArray<GstMpegts.AtscVCTSource> sources;
		public uint16 transport_stream_id;
	}
	[CCode (cheader_filename = "gst/mpegts/mpegts.h", copy_function = "g_boxed_copy", free_function = "g_boxed_free", type_id = "gst_mpegts_atsc_vct_source_get_type ()")]
	[Compact]
	public class AtscVCTSource {
		public uint8 ETM_location;
		public bool access_controlled;
		public uint32 carrier_frequency;
		public uint16 channel_TSID;
		public weak GLib.GenericArray<GstMpegts.Descriptor> descriptors;
		public bool hidden;
		public bool hide_guide;
		public uint16 major_channel_number;
		public uint16 minor_channel_number;
		public uint8 modulation_mode;
		public bool out_of_band;
		public bool path_select;
		public uint16 program_number;
		public uint8 service_type;
		public weak string short_name;
		public uint16 source_id;
	}
	[CCode (cheader_filename = "gst/mpegts/mpegts.h", copy_function = "g_boxed_copy", free_function = "g_boxed_free", type_id = "gst_mpegts_bat_get_type ()")]
	[Compact]
	public class BAT {
		public weak GLib.GenericArray<GstMpegts.Descriptor> descriptors;
		public weak GLib.GenericArray<GstMpegts.BATStream> streams;
	}
	[CCode (cheader_filename = "gst/mpegts/mpegts.h", copy_function = "g_boxed_copy", free_function = "g_boxed_free", type_id = "gst_mpegts_bat_stream_get_type ()")]
	[Compact]
	public class BATStream {
		public weak GLib.GenericArray<void*> descriptors;
		public uint16 original_network_id;
		public uint16 transport_stream_id;
	}
	[CCode (cheader_filename = "gst/mpegts/mpegts.h", copy_function = "g_boxed_copy", free_function = "g_boxed_free", type_id = "gst_mpegts_component_descriptor_get_type ()")]
	[Compact]
	public class ComponentDescriptor {
		public uint8 component_tag;
		public uint8 component_type;
		public weak string language_code;
		public uint8 stream_content;
		public weak string text;
	}
	[CCode (cheader_filename = "gst/mpegts/mpegts.h", copy_function = "g_boxed_copy", free_function = "g_boxed_free", type_id = "gst_mpegts_dvb_linkage_descriptor_get_type ()")]
	[Compact]
	public class DVBLinkageDescriptor {
		public void* linkage_data;
		public GstMpegts.DVBLinkageType linkage_type;
		public uint16 original_network_id;
		public uint8 private_data_bytes;
		public uint8 private_data_length;
		public uint16 service_id;
		public uint16 transport_stream_id;
		public void free ();
	}
	[CCode (cheader_filename = "gst/mpegts/mpegts.h", copy_function = "g_boxed_copy", free_function = "g_boxed_free", lower_case_csuffix = "dvb_data_broadcast_descriptor", type_id = "gst_mpegts_dvb_data_broadcast_descriptor_get_type ()")]
	[Compact]
	public class DataBroadcastDescriptor {
		public uint8 component_tag;
		public uint16 data_broadcast_id;
		public weak string language_code;
		public uint8 length;
		public uint8 selector_bytes;
		public weak string text;
		public void free ();
	}
	[CCode (cheader_filename = "gst/mpegts/mpegts.h", copy_function = "g_boxed_copy", free_function = "g_boxed_free", type_id = "gst_mpegts_descriptor_get_type ()")]
	[Compact]
	public class Descriptor {
		public uint8 data;
		public uint8 length;
		public uint8 tag;
		public uint8 tag_extension;
		public static GstMpegts.Descriptor from_custom (uint8 tag, uint8 data, size_t length);
		public static GstMpegts.Descriptor from_dvb_network_name (string name);
		public static GstMpegts.Descriptor from_dvb_service (GstMpegts.DVBServiceType service_type, string? service_name, string? service_provider);
		public static GstMpegts.Descriptor from_dvb_subtitling (string lang, uint8 type, uint16 composition, uint16 ancillary);
		public static GstMpegts.Descriptor from_registration (string format_identifier, uint8? additional_info, size_t additional_info_length);
		public bool parse_cable_delivery_system (out GstMpegts.CableDeliverySystemDescriptor res);
		public bool parse_dvb_bouquet_name (out string bouquet_name);
		public bool parse_dvb_ca_identifier (out GLib.Array<uint16> list);
		public bool parse_dvb_component (out GstMpegts.ComponentDescriptor res);
		public bool parse_dvb_content (out GLib.GenericArray<GstMpegts.Content> content);
		public bool parse_dvb_data_broadcast (out GstMpegts.DataBroadcastDescriptor res);
		public bool parse_dvb_data_broadcast_id (out uint16 data_broadcast_id, out uint8 id_selector_bytes, out uint8 len);
		public bool parse_dvb_extended_event (out GstMpegts.ExtendedEventDescriptor res);
		public bool parse_dvb_frequency_list (out bool offset, out GLib.Array<uint32> list);
		public bool parse_dvb_linkage (out GstMpegts.DVBLinkageDescriptor res);
		public bool parse_dvb_multilingual_bouquet_name (out GLib.GenericArray<GstMpegts.DvbMultilingualBouquetNameItem> bouquet_name_items);
		public bool parse_dvb_multilingual_component (uint8 component_tag, out GLib.GenericArray<GstMpegts.DvbMultilingualComponentItem> component_description_items);
		public bool parse_dvb_multilingual_network_name (out GLib.GenericArray<GstMpegts.DvbMultilingualNetworkNameItem> network_name_items);
		public bool parse_dvb_multilingual_service_name (out GLib.GenericArray<GstMpegts.DvbMultilingualServiceNameItem> service_name_items);
		public bool parse_dvb_network_name (out string name);
		public bool parse_dvb_parental_rating (out GLib.GenericArray<GstMpegts.DVBParentalRatingItem> rating);
		public bool parse_dvb_private_data_specifier (out uint32 private_data_specifier, out uint8 private_data, out uint8 length);
		public bool parse_dvb_scrambling (out GstMpegts.DVBScramblingModeType scrambling_mode);
		public bool parse_dvb_service (out GstMpegts.DVBServiceType service_type, out string service_name, out string provider_name);
		public bool parse_dvb_service_list (out GLib.GenericArray<GstMpegts.DVBServiceListItem> list);
		public bool parse_dvb_short_event (out string language_code, out string event_name, out string text);
		public bool parse_dvb_stream_identifier (out uint8 component_tag);
		public bool parse_dvb_stuffing (out uint8 stuffing_bytes);
		public bool parse_dvb_subtitling_idx (uint idx, out string lang, out uint8 type, out uint16 composition_page_id, out uint16 ancillary_page_id);
		public uint parse_dvb_subtitling_nb ();
		public bool parse_dvb_t2_delivery_system (out GstMpegts.T2DeliverySystemDescriptor res);
		public bool parse_dvb_teletext_idx (uint idx, out string language_code, out GstMpegts.DVBTeletextType teletext_type, out uint8 magazine_number, out uint8 page_number);
		public uint parse_dvb_teletext_nb ();
		public bool parse_iso_639_language (out GstMpegts.ISO639LanguageDescriptor res);
		public bool parse_iso_639_language_idx (uint idx, out string lang, out GstMpegts.Iso639AudioType audio_type);
		public uint parse_iso_639_language_nb ();
		public bool parse_logical_channel (out GstMpegts.LogicalChannelDescriptor res);
		public bool parse_satellite_delivery_system (out GstMpegts.SatelliteDeliverySystemDescriptor res);
		public bool parse_terrestrial_delivery_system (out GstMpegts.TerrestrialDeliverySystemDescriptor res);
	}
	[CCode (cheader_filename = "gst/mpegts/mpegts.h", copy_function = "g_boxed_copy", free_function = "g_boxed_free", type_id = "gst_mpegts_eit_get_type ()")]
	[Compact]
	public class EIT {
		public bool actual_stream;
		public weak GLib.GenericArray<GstMpegts.EITEvent> events;
		public uint8 last_table_id;
		public uint16 original_network_id;
		public bool present_following;
		public uint8 segment_last_section_number;
		public uint16 transport_stream_id;
	}
	[CCode (cheader_filename = "gst/mpegts/mpegts.h", copy_function = "g_boxed_copy", free_function = "g_boxed_free", type_id = "gst_mpegts_eit_event_get_type ()")]
	[Compact]
	public class EITEvent {
		public weak GLib.GenericArray<GstMpegts.Descriptor> descriptors;
		public uint32 duration;
		public uint16 event_id;
		public bool free_CA_mode;
		public GstMpegts.RunningStatus running_status;
		public weak Gst.DateTime start_time;
	}
	[CCode (cheader_filename = "gst/mpegts/mpegts.h", copy_function = "g_boxed_copy", free_function = "g_boxed_free", type_id = "gst_mpegts_extended_event_descriptor_get_type ()")]
	[Compact]
	public class ExtendedEventDescriptor {
		public uint8 descriptor_number;
		public weak GLib.GenericArray<GstMpegts.ExtendedEventItem> items;
		public weak string language_code;
		public uint8 last_descriptor_number;
		public weak string text;
		public void free ();
	}
	[CCode (cheader_filename = "gst/mpegts/mpegts.h", copy_function = "g_boxed_copy", free_function = "g_boxed_free", lower_case_csuffix = "iso_639_language", type_id = "gst_mpegts_iso_639_language_get_type ()")]
	[Compact]
	public class ISO639LanguageDescriptor {
		[CCode (array_length = false, array_null_terminated = true)]
		public weak GstMpegts.Iso639AudioType[] audio_type;
		[CCode (array_length = false, array_null_terminated = true)]
		public weak string[] language;
		public uint nb_language;
		public void descriptor_free ();
	}
	[CCode (cheader_filename = "gst/mpegts/mpegts.h", copy_function = "g_boxed_copy", free_function = "g_boxed_free", type_id = "gst_mpegts_nit_get_type ()")]
	[Compact]
	public class NIT {
		public bool actual_network;
		public weak GLib.GenericArray<GstMpegts.Descriptor> descriptors;
		public uint16 network_id;
		public weak GLib.GenericArray<GstMpegts.NITStream> streams;
		[CCode (has_construct_function = false)]
		public NIT ();
	}
	[CCode (cheader_filename = "gst/mpegts/mpegts.h", copy_function = "g_boxed_copy", free_function = "g_boxed_free", type_id = "gst_mpegts_nit_stream_get_type ()")]
	[Compact]
	public class NITStream {
		public weak GLib.GenericArray<GstMpegts.Descriptor> descriptors;
		public uint16 original_network_id;
		public uint16 transport_stream_id;
		[CCode (has_construct_function = false)]
		public NITStream ();
	}
	[CCode (cheader_filename = "gst/mpegts/mpegts.h", copy_function = "g_boxed_copy", free_function = "g_boxed_free", type_id = "gst_mpegts_pmt_get_type ()")]
	[Compact]
	public class PMT {
		public weak GLib.GenericArray<GstMpegts.Descriptor> descriptors;
		public uint16 pcr_pid;
		public uint16 program_number;
		public weak GLib.GenericArray<GstMpegts.PMTStream> streams;
		[CCode (has_construct_function = false)]
		public PMT ();
	}
	[CCode (cheader_filename = "gst/mpegts/mpegts.h", copy_function = "g_boxed_copy", free_function = "g_boxed_free", type_id = "gst_mpegts_pmt_stream_get_type ()")]
	[Compact]
	public class PMTStream {
		public weak GLib.GenericArray<GstMpegts.Descriptor> descriptors;
		public uint16 pid;
		public uint8 stream_type;
		[CCode (has_construct_function = false)]
		public PMTStream ();
	}
	[CCode (cheader_filename = "gst/mpegts/mpegts.h", copy_function = "g_boxed_copy", free_function = "g_boxed_free", type_id = "gst_mpegts_pat_program_get_type ()")]
	[Compact]
	public class PatProgram {
		public uint16 network_or_program_map_PID;
		public uint16 program_number;
		[CCode (has_construct_function = false)]
		public PatProgram ();
	}
	[CCode (cheader_filename = "gst/mpegts/mpegts.h", copy_function = "g_boxed_copy", free_function = "g_boxed_free", type_id = "gst_mpegts_sdt_get_type ()")]
	[Compact]
	public class SDT {
		public bool actual_ts;
		public uint16 original_network_id;
		public weak GLib.GenericArray<GstMpegts.SDTService> services;
		public uint16 transport_stream_id;
		[CCode (has_construct_function = false)]
		public SDT ();
	}
	[CCode (cheader_filename = "gst/mpegts/mpegts.h", copy_function = "g_boxed_copy", free_function = "g_boxed_free", type_id = "gst_mpegts_sdt_service_get_type ()")]
	[Compact]
	public class SDTService {
		public bool EIT_present_following_flag;
		public bool EIT_schedule_flag;
		public weak GLib.GenericArray<GstMpegts.Descriptor> descriptors;
		public bool free_CA_mode;
		public GstMpegts.RunningStatus running_status;
		public uint16 service_id;
		[CCode (has_construct_function = false)]
		public SDTService ();
	}
	[CCode (cheader_filename = "gst/mpegts/mpegts.h", copy_function = "g_boxed_copy", free_function = "g_boxed_free", type_id = "gst_mpegts_section_get_type ()")]
	[Compact]
	public class Section {
		public uint32 crc;
		public bool current_next_indicator;
		public uint8 last_section_number;
		public uint16 pid;
		public uint8 section_number;
		public GstMpegts.SectionType section_type;
		public uint16 subtable_extension;
		public uint8 table_id;
		public uint8 version_number;
		[CCode (has_construct_function = false)]
		public Section (uint16 pid, owned uint8 data, size_t data_size);
		public static GstMpegts.Section from_nit (owned GstMpegts.NIT nit);
		public static GstMpegts.Section from_pat (owned GLib.GenericArray<GstMpegts.PatProgram> programs, uint16 ts_id);
		public static GstMpegts.Section from_pmt (owned GstMpegts.PMT pmt, uint16 pid);
		public static GstMpegts.Section from_sdt (owned GstMpegts.SDT sdt);
		public unowned GstMpegts.AtscVCT get_atsc_cvct ();
		public unowned GstMpegts.AtscEIT get_atsc_eit ();
		public unowned GstMpegts.AtscETT get_atsc_ett ();
		public unowned GstMpegts.AtscMGT get_atsc_mgt ();
		public unowned GstMpegts.AtscSTT get_atsc_stt ();
		public unowned GstMpegts.AtscVCT get_atsc_tvct ();
		public unowned GstMpegts.BAT get_bat ();
		public GLib.GenericArray<weak GstMpegts.Descriptor> get_cat ();
		public GLib.Bytes get_data ();
		public unowned GstMpegts.EIT get_eit ();
		public unowned GstMpegts.NIT get_nit ();
		public GLib.GenericArray<weak GstMpegts.PatProgram> get_pat ();
		public unowned GstMpegts.PMT get_pmt ();
		public unowned GstMpegts.SDT get_sdt ();
		public Gst.DateTime get_tdt ();
		public unowned GstMpegts.TOT get_tot ();
		public GLib.GenericArray<weak GstMpegts.Descriptor> get_tsdt ();
		public uint8 packetize (out size_t output_size);
		public bool send_event (Gst.Element element);
	}
	[CCode (cheader_filename = "gst/mpegts/mpegts.h", copy_function = "g_boxed_copy", free_function = "g_boxed_free", type_id = "gst_mpegts_t2_delivery_system_descriptor_get_type ()")]
	[Compact]
	public class T2DeliverySystemDescriptor {
		public uint32 bandwidth;
		public weak GLib.GenericArray<GstMpegts.T2DeliverySystemCell> cells;
		public GstMpegts.TerrestrialGuardInterval guard_interval;
		public bool other_frequency;
		public uint8 plp_id;
		public uint8 siso_miso;
		public uint16 t2_system_id;
		public bool tfs;
		public GstMpegts.TerrestrialTransmissionMode transmission_mode;
		public void free ();
	}
	[CCode (cheader_filename = "gst/mpegts/mpegts.h", copy_function = "g_boxed_copy", free_function = "g_boxed_free", type_id = "gst_mpegts_tot_get_type ()")]
	[Compact]
	public class TOT {
		public weak GLib.GenericArray<GstMpegts.Descriptor> descriptors;
		public weak Gst.DateTime utc_time;
	}
	[CCode (cheader_filename = "gst/mpegts/mpegts.h", has_type_id = false)]
	public struct CableDeliverySystemDescriptor {
		public uint32 frequency;
		public GstMpegts.CableOuterFECScheme outer_fec;
		public GstMpegts.ModulationType modulation;
		public uint32 symbol_rate;
		public GstMpegts.DVBCodeRate fec_inner;
	}
	[CCode (cheader_filename = "gst/mpegts/mpegts.h", has_type_id = false)]
	public struct Content {
		public GstMpegts.ContentNibbleHi content_nibble_1;
		public uint8 content_nibble_2;
		public uint8 user_byte;
	}
	[CCode (cheader_filename = "gst/mpegts/mpegts.h", has_type_id = false)]
	public struct DVBLinkageEvent {
		public uint16 target_event_id;
		public bool target_listed;
		public bool event_simulcast;
	}
	[CCode (cheader_filename = "gst/mpegts/mpegts.h", has_type_id = false)]
	public struct DVBLinkageExtendedEvent {
		public uint16 target_event_id;
		public bool target_listed;
		public bool event_simulcast;
		public uint8 link_type;
		public uint8 target_id_type;
		public bool original_network_id_flag;
		public bool service_id_flag;
		public uint16 user_defined_id;
		public uint16 target_transport_stream_id;
		public uint16 target_original_network_id;
		public uint16 target_service_id;
	}
	[CCode (cheader_filename = "gst/mpegts/mpegts.h", has_type_id = false)]
	public struct DVBLinkageMobileHandOver {
		public GstMpegts.DVBLinkageHandOverType hand_over_type;
		public bool origin_type;
		public uint16 network_id;
		public uint16 initial_service_id;
	}
	[CCode (cheader_filename = "gst/mpegts/mpegts.h", has_type_id = false)]
	public struct DVBParentalRatingItem {
		public weak string country_code;
		public uint8 rating;
	}
	[CCode (cheader_filename = "gst/mpegts/mpegts.h", has_type_id = false)]
	public struct DVBServiceListItem {
		public uint16 service_id;
		public GstMpegts.DVBServiceType type;
	}
	[CCode (cheader_filename = "gst/mpegts/mpegts.h", has_type_id = false)]
	public struct DvbMultilingualBouquetNameItem {
		public weak string language_code;
		public weak string bouquet_name;
	}
	[CCode (cheader_filename = "gst/mpegts/mpegts.h", has_type_id = false)]
	public struct DvbMultilingualComponentItem {
		public weak string language_code;
		public weak string description;
	}
	[CCode (cheader_filename = "gst/mpegts/mpegts.h", has_type_id = false)]
	public struct DvbMultilingualNetworkNameItem {
		public weak string language_code;
		public weak string network_name;
	}
	[CCode (cheader_filename = "gst/mpegts/mpegts.h", has_type_id = false)]
	public struct DvbMultilingualServiceNameItem {
		public weak string language_code;
		public weak string provider_name;
		public weak string service_name;
	}
	[CCode (cheader_filename = "gst/mpegts/mpegts.h", has_type_id = false)]
	public struct ExtendedEventItem {
		public weak string item_description;
		public weak string item;
	}
	[CCode (cheader_filename = "gst/mpegts/mpegts.h", has_type_id = false)]
	public struct LogicalChannel {
		public uint16 service_id;
		public bool visible_service;
		public uint16 logical_channel_number;
	}
	[CCode (cheader_filename = "gst/mpegts/mpegts.h", has_type_id = false)]
	public struct LogicalChannelDescriptor {
		public uint nb_channels;
		[CCode (array_length = false, array_null_terminated = true)]
		public weak GstMpegts.LogicalChannel[] channels;
	}
	[CCode (cheader_filename = "gst/mpegts/mpegts.h", has_type_id = false)]
	public struct SatelliteDeliverySystemDescriptor {
		public uint32 frequency;
		public float orbital_position;
		public bool west_east;
		public GstMpegts.SatellitePolarizationType polarization;
		public GstMpegts.SatelliteRolloff roll_off;
		public bool modulation_system;
		public GstMpegts.ModulationType modulation_type;
		public uint32 symbol_rate;
		public GstMpegts.DVBCodeRate fec_inner;
	}
	[CCode (cheader_filename = "gst/mpegts/mpegts.h", has_type_id = false)]
	public struct T2DeliverySystemCell {
		public uint16 cell_id;
		public weak GLib.Array<void*> centre_frequencies;
		public weak GLib.GenericArray<GstMpegts.T2DeliverySystemCellExtension> sub_cells;
	}
	[CCode (cheader_filename = "gst/mpegts/mpegts.h", has_type_id = false)]
	public struct T2DeliverySystemCellExtension {
		public uint8 cell_id_extension;
		public uint32 transposer_frequency;
	}
	[CCode (cheader_filename = "gst/mpegts/mpegts.h", has_type_id = false)]
	public struct TerrestrialDeliverySystemDescriptor {
		public uint32 frequency;
		public uint32 bandwidth;
		public bool priority;
		public bool time_slicing;
		public bool mpe_fec;
		public GstMpegts.ModulationType constellation;
		public GstMpegts.TerrestrialHierarchy hierarchy;
		public GstMpegts.DVBCodeRate code_rate_hp;
		public GstMpegts.DVBCodeRate code_rate_lp;
		public GstMpegts.TerrestrialGuardInterval guard_interval;
		public GstMpegts.TerrestrialTransmissionMode transmission_mode;
		public bool other_frequency;
	}
	[CCode (cheader_filename = "gst/mpegts/mpegts.h", cprefix = "GST_MTS_DESC_ATSC_", has_type_id = false)]
	public enum ATSCDescriptorType {
		STUFFING,
		AC3,
		CAPTION_SERVICE,
		CONTENT_ADVISORY,
		EXTENDED_CHANNEL_NAME,
		SERVICE_LOCATION,
		TIME_SHIFTED_SERVICE,
		COMPONENT_NAME,
		DCC_DEPARTING_REQUEST,
		DCC_ARRIVING_REQUEST,
		REDISTRIBUTION_CONTROL,
		GENRE,
		PRIVATE_INFORMATION,
		ENHANCED_SIGNALING,
		DATA_SERVICE,
		PID_COUNT,
		DOWNLOAD_DESCRIPTOR,
		MULTIPROTOCOL_ENCAPSULATION,
		MODULE_LINK,
		CRC32,
		GROUP_LINK
	}
	[CCode (cheader_filename = "gst/mpegts/mpegts.h", cprefix = "GST_MPEGTS_ATSC_MGT_TABLE_TYPE_", has_type_id = false)]
	public enum AtscMGTTableType {
		EIT0,
		EIT127,
		ETT0,
		ETT127
	}
	[CCode (cheader_filename = "gst/mpegts/mpegts.h", cprefix = "GST_MPEGTS_CABLE_OUTER_FEC_", has_type_id = false)]
	public enum CableOuterFECScheme {
		UNDEFINED,
		NONE,
		RS_204_188
	}
	[CCode (cheader_filename = "gst/mpegts/mpegts.h", cprefix = "GST_MPEGTS_STREAM_CONTENT_", has_type_id = false)]
	public enum ComponentStreamContent {
		MPEG2_VIDEO,
		MPEG1_LAYER2_AUDIO,
		TELETEXT_OR_SUBTITLE,
		AC_3,
		AVC,
		AAC,
		DTS,
		SRM_CPCM
	}
	[CCode (cheader_filename = "gst/mpegts/mpegts.h", cprefix = "GST_MPEGTS_CONTENT_", has_type_id = false)]
	public enum ContentNibbleHi {
		MOVIE_DRAMA,
		NEWS_CURRENT_AFFAIRS,
		SHOW_GAME_SHOW,
		SPORTS,
		CHILDREN_YOUTH_PROGRAM,
		MUSIC_BALLET_DANCE,
		ARTS_CULTURE,
		SOCIAL_POLITICAL_ECONOMICS,
		EDUCATION_SCIENCE_FACTUAL,
		LEISURE_HOBBIES,
		SPECIAL_CHARACTERISTICS
	}
	[CCode (cheader_filename = "gst/mpegts/mpegts.h", cprefix = "GST_MPEGTS_FEC_", has_type_id = false)]
	public enum DVBCodeRate {
		NONE,
		@1_2,
		@2_3,
		@3_4,
		@4_5,
		@5_6,
		@6_7,
		@7_8,
		@8_9,
		AUTO,
		@3_5,
		@9_10,
		@2_5
	}
	[CCode (cheader_filename = "gst/mpegts/mpegts.h", cprefix = "GST_MTS_DESC_DVB_", has_type_id = false)]
	public enum DVBDescriptorType {
		NETWORK_NAME,
		SERVICE_LIST,
		STUFFING,
		SATELLITE_DELIVERY_SYSTEM,
		CABLE_DELIVERY_SYSTEM,
		VBI_DATA,
		VBI_TELETEXT,
		BOUQUET_NAME,
		SERVICE,
		COUNTRY_AVAILABILITY,
		LINKAGE,
		NVOD_REFERENCE,
		TIME_SHIFTED_SERVICE,
		SHORT_EVENT,
		EXTENDED_EVENT,
		TIME_SHIFTED_EVENT,
		COMPONENT,
		MOSAIC,
		STREAM_IDENTIFIER,
		CA_IDENTIFIER,
		CONTENT,
		PARENTAL_RATING,
		TELETEXT,
		TELEPHONE,
		LOCAL_TIME_OFFSET,
		SUBTITLING,
		TERRESTRIAL_DELIVERY_SYSTEM,
		MULTILINGUAL_NETWORK_NAME,
		MULTILINGUAL_BOUQUET_NAME,
		MULTILINGUAL_SERVICE_NAME,
		MULTILINGUAL_COMPONENT,
		PRIVATE_DATA_SPECIFIER,
		SERVICE_MOVE,
		SHORT_SMOOTHING_BUFFER,
		FREQUENCY_LIST,
		PARTIAL_TRANSPORT_STREAM,
		DATA_BROADCAST,
		SCRAMBLING,
		DATA_BROADCAST_ID,
		TRANSPORT_STREAM,
		DSNG,
		PDC,
		AC3,
		ANCILLARY_DATA,
		CELL_LIST,
		CELL_FREQUENCY_LINK,
		ANNOUNCEMENT_SUPPORT,
		APPLICATION_SIGNALLING,
		ADAPTATION_FIELD_DATA,
		SERVICE_IDENTIFIER,
		SERVICE_AVAILABILITY,
		DEFAULT_AUTHORITY,
		RELATED_CONTENT,
		TVA_ID,
		CONTENT_IDENTIFIER,
		TIMESLICE_FEC_IDENTIFIER,
		ECM_REPETITION_RATE,
		S2_SATELLITE_DELIVERY_SYSTEM,
		ENHANCED_AC3,
		DTS,
		AAC,
		XAIT_LOCATION,
		FTA_CONTENT_MANAGEMENT,
		EXTENSION
	}
	[CCode (cheader_filename = "gst/mpegts/mpegts.h", cprefix = "GST_MTS_DESC_EXT_DVB_", has_type_id = false)]
	public enum DVBExtendedDescriptorType {
		IMAGE_ICON,
		CPCM_DELIVERY_SIGNALLING,
		CP,
		CP_IDENTIFIER,
		T2_DELIVERY_SYSTEM,
		SH_DELIVERY_SYSTEM,
		SUPPLEMENTARY_AUDIO,
		NETWORK_CHANGE_NOTIFY,
		MESSAGE,
		TARGET_REGION,
		TARGET_REGION_NAME,
		SERVICE_RELOCATED,
		XAIT_PID,
		C2_DELIVERY_SYSTEM,
		DTS_HD_AUDIO_STREAM,
		DTS_NEUTRAL,
		VIDEO_DEPTH_RANGE,
		T2MI,
		URI_LINKAGE
	}
	[CCode (cheader_filename = "gst/mpegts/mpegts.h", cprefix = "GST_MPEGTS_DVB_LINKAGE_HAND_OVER_", has_type_id = false)]
	public enum DVBLinkageHandOverType {
		RESERVED,
		IDENTICAL,
		LOCAL_VARIATION,
		ASSOCIATED
	}
	[CCode (cheader_filename = "gst/mpegts/mpegts.h", cprefix = "GST_MPEGTS_DVB_LINKAGE_", has_type_id = false)]
	public enum DVBLinkageType {
		RESERVED_00,
		INFORMATION,
		EPG,
		CA_REPLACEMENT,
		TS_CONTAINING_COMPLETE_SI,
		SERVICE_REPLACEMENT,
		DATA_BROADCAST,
		RCS_MAP,
		MOBILE_HAND_OVER,
		SYSTEM_SOFTWARE_UPDATE,
		TS_CONTAINING_SSU,
		IP_MAC_NOTIFICATION,
		TS_CONTAINING_INT,
		EVENT,
		EXTENDED_EVENT
	}
	[CCode (cheader_filename = "gst/mpegts/mpegts.h", cprefix = "GST_MPEGTS_DVB_SCRAMBLING_MODE_", has_type_id = false)]
	public enum DVBScramblingModeType {
		RESERVED,
		CSA1,
		CSA2,
		CSA3_STANDARD,
		CSA3_MINIMAL_ENHANCED,
		CSA3_FULL_ENHANCED,
		CISSA,
		ATIS_0,
		ATIS_F
	}
	[CCode (cheader_filename = "gst/mpegts/mpegts.h", cprefix = "GST_DVB_SERVICE_", has_type_id = false)]
	public enum DVBServiceType {
		RESERVED_00,
		DIGITAL_TELEVISION,
		DIGITAL_RADIO_SOUND,
		TELETEXT,
		NVOD_REFERENCE,
		NVOD_TIME_SHIFTED,
		MOSAIC,
		FM_RADIO,
		DVB_SRM,
		RESERVED_09,
		ADVANCED_CODEC_DIGITAL_RADIO_SOUND,
		ADVANCED_CODEC_MOSAIC,
		DATA_BROADCAST,
		RESERVED_0D_COMMON_INTERFACE,
		RCS_MAP,
		RCS_FLS,
		DVB_MHP,
		MPEG2_HD_DIGITAL_TELEVISION,
		ADVANCED_CODEC_SD_DIGITAL_TELEVISION,
		ADVANCED_CODEC_SD_NVOD_TIME_SHIFTED,
		ADVANCED_CODEC_SD_NVOD_REFERENCE,
		ADVANCED_CODEC_HD_DIGITAL_TELEVISION,
		ADVANCED_CODEC_HD_NVOD_TIME_SHIFTED,
		ADVANCED_CODEC_HD_NVOD_REFERENCE,
		ADVANCED_CODEC_STEREO_HD_DIGITAL_TELEVISION,
		ADVANCED_CODEC_STEREO_HD_NVOD_TIME_SHIFTED,
		ADVANCED_CODEC_STEREO_HD_NVOD_REFERENCE,
		RESERVED_FF
	}
	[CCode (cheader_filename = "gst/mpegts/mpegts.h", cprefix = "", has_type_id = false)]
	public enum DVBTeletextType {
		[CCode (cname = "INITIAL_PAGE")]
		NITIAL_PAGE,
		[CCode (cname = "SUBTITLE_PAGE")]
		UBTITLE_PAGE,
		[CCode (cname = "ADDITIONAL_INFO_PAGE")]
		DDITIONAL_INFO_PAGE,
		[CCode (cname = "PROGRAMME_SCHEDULE_PAGE")]
		ROGRAMME_SCHEDULE_PAGE,
		[CCode (cname = "HEARING_IMPAIRED_PAGE")]
		EARING_IMPAIRED_PAGE
	}
	[CCode (cheader_filename = "gst/mpegts/mpegts.h", cprefix = "GST_MTS_DESC_", has_type_id = false)]
	public enum DescriptorType {
		RESERVED_00,
		RESERVED_01,
		VIDEO_STREAM,
		AUDIO_STREAM,
		HIERARCHY,
		REGISTRATION,
		DATA_STREAM_ALIGNMENT,
		TARGET_BACKGROUND_GRID,
		VIDEO_WINDOW,
		CA,
		ISO_639_LANGUAGE,
		SYSTEM_CLOCK,
		MULTIPLEX_BUFFER_UTILISATION,
		COPYRIGHT,
		MAXIMUM_BITRATE,
		PRIVATE_DATA_INDICATOR,
		SMOOTHING_BUFFER,
		STD,
		IBP,
		DSMCC_CAROUSEL_IDENTIFIER,
		DSMCC_ASSOCIATION_TAG,
		DSMCC_DEFERRED_ASSOCIATION_TAG,
		DSMCC_NPT_REFERENCE,
		DSMCC_NPT_ENDPOINT,
		DSMCC_STREAM_MODE,
		DSMCC_STREAM_EVENT,
		MPEG4_VIDEO,
		MPEG4_AUDIO,
		IOD,
		SL,
		FMC,
		EXTERNAL_ES_ID,
		MUX_CODE,
		FMX_BUFFER_SIZE,
		MULTIPLEX_BUFFER,
		CONTENT_LABELING,
		METADATA_POINTER,
		METADATA,
		METADATA_STD,
		AVC_VIDEO,
		IPMP,
		AVC_TIMING_AND_HRD,
		MPEG2_AAC_AUDIO,
		FLEX_MUX_TIMING,
		MPEG4_TEXT,
		MPEG4_AUDIO_EXTENSION,
		AUXILIARY_VIDEO_STREAM,
		SVC_EXTENSION,
		MVC_EXTENSION,
		J2K_VIDEO,
		MVC_OPERATION_POINT,
		MPEG2_STEREOSCOPIC_VIDEO_FORMAT,
		STEREOSCOPIC_PROGRAM_INFO,
		STEREOSCOPIC_VIDEO_INFO
	}
	[CCode (cheader_filename = "gst/mpegts/mpegts.h", cprefix = "GST_MTS_DESC_ISDB_", has_type_id = false)]
	public enum ISDBDescriptorType {
		HIERARCHICAL_TRANSMISSION,
		DIGITAL_COPY_CONTROL,
		NETWORK_IDENTIFICATION,
		PARTIAL_TS_TIME,
		AUDIO_COMPONENT,
		HYPERLINK,
		TARGET_REGION,
		DATA_CONTENT,
		VIDEO_DECODE_CONTROL,
		DOWNLOAD_CONTENT,
		CA_EMM_TS,
		CA_CONTRACT_INFORMATION,
		CA_SERVICE,
		TS_INFORMATION,
		EXTENDED_BROADCASTER,
		LOGO_TRANSMISSION,
		BASIC_LOCAL_EVENT,
		REFERENCE,
		NODE_RELATION,
		SHORT_NODE_INFORMATION,
		STC_REFERENCE,
		SERIES,
		EVENT_GROUP,
		SI_PARAMETER,
		BROADCASTER_NAME,
		COMPONENT_GROUP,
		SI_PRIME_TS,
		BOARD_INFORMATION,
		LDT_LINKAGE,
		CONNECTED_TRANSMISSION,
		CONTENT_AVAILABILITY,
		SERVICE_GROUP
	}
	[CCode (cheader_filename = "gst/mpegts/mpegts.h", cprefix = "GST_MPEGTS_AUDIO_TYPE_", has_type_id = false)]
	public enum Iso639AudioType {
		UNDEFINED,
		CLEAN_EFFECTS,
		HEARING_IMPAIRED,
		VISUAL_IMPAIRED_COMMENTARY
	}
	[CCode (cheader_filename = "gst/mpegts/mpegts.h", cprefix = "GST_MTS_DESC_", has_type_id = false)]
	public enum MiscDescriptorType {
		AC3_AUDIO_STREAM,
		DTG_LOGICAL_CHANNEL
	}
	[CCode (cheader_filename = "gst/mpegts/mpegts.h", cprefix = "GST_MPEGTS_MODULATION_", has_type_id = false)]
	public enum ModulationType {
		QPSK,
		QAM_16,
		QAM_32,
		QAM_64,
		QAM_128,
		QAM_256,
		QAM_AUTO,
		VSB_8,
		VSB_16,
		PSK_8,
		APSK_16,
		APSK_32,
		DQPSK,
		QAM_4_NR_,
		NONE
	}
	[CCode (cheader_filename = "gst/mpegts/mpegts.h", cprefix = "GST_MPEGTS_RUNNING_STATUS_", has_type_id = false)]
	public enum RunningStatus {
		UNDEFINED,
		NOT_RUNNING,
		STARTS_IN_FEW_SECONDS,
		PAUSING,
		RUNNING,
		OFF_AIR
	}
	[CCode (cheader_filename = "gst/mpegts/mpegts.h", cprefix = "GST_MPEGTS_POLARIZATION_", has_type_id = false)]
	public enum SatellitePolarizationType {
		LINEAR_HORIZONTAL,
		LINEAR_VERTICAL,
		CIRCULAR_LEFT,
		CIRCULAR_RIGHT
	}
	[CCode (cheader_filename = "gst/mpegts/mpegts.h", cprefix = "GST_MPEGTS_ROLLOFF_", has_type_id = false)]
	public enum SatelliteRolloff {
		@35,
		@20,
		@25,
		RESERVED,
		AUTO
	}
	[CCode (cheader_filename = "gst/mpegts/mpegts.h", cprefix = "GST_MPEGTS_STREAM_TYPE_SCTE_", has_type_id = false)]
	public enum ScteStreamType {
		SUBTITLING,
		ISOCH_DATA,
		DST_NRT,
		DSMCC_DCB,
		SIGNALING,
		SYNC_DATA,
		ASYNC_DATA
	}
	[CCode (cheader_filename = "gst/mpegts/mpegts.h", cprefix = "GST_MTS_TABLE_ID_ATSC_", has_type_id = false)]
	public enum SectionATSCTableID {
		MASTER_GUIDE,
		TERRESTRIAL_VIRTUAL_CHANNEL,
		CABLE_VIRTUAL_CHANNEL,
		RATING_REGION,
		EVENT_INFORMATION,
		CHANNEL_OR_EVENT_EXTENDED_TEXT,
		SYSTEM_TIME,
		DATA_EVENT,
		DATA_SERVICE,
		NETWORK_RESOURCE,
		LONG_TERM_SERVICE,
		DIRECTED_CHANNEL_CHANGE,
		DIRECTED_CHANNEL_CHANGE_SECTION_CODE,
		AGGREGATE_EVENT_INFORMATION,
		AGGREGATE_EXTENDED_TEXT,
		AGGREGATE_DATA_EVENT,
		SATELLITE_VIRTUAL_CHANNEL
	}
	[CCode (cheader_filename = "gst/mpegts/mpegts.h", cprefix = "GST_MTS_TABLE_ID_", has_type_id = false)]
	public enum SectionDVBTableID {
		NETWORK_INFORMATION_ACTUAL_NETWORK,
		NETWORK_INFORMATION_OTHER_NETWORK,
		SERVICE_DESCRIPTION_ACTUAL_TS,
		SERVICE_DESCRIPTION_OTHER_TS,
		BOUQUET_ASSOCIATION,
		EVENT_INFORMATION_ACTUAL_TS_PRESENT,
		EVENT_INFORMATION_OTHER_TS_PRESENT,
		EVENT_INFORMATION_ACTUAL_TS_SCHEDULE_1,
		EVENT_INFORMATION_ACTUAL_TS_SCHEDULE_N,
		EVENT_INFORMATION_OTHER_TS_SCHEDULE_1,
		EVENT_INFORMATION_OTHER_TS_SCHEDULE_N,
		TIME_DATE,
		RUNNING_STATUS,
		STUFFING,
		TIME_OFFSET,
		APPLICATION_INFORMATION_TABLE,
		CONTAINER,
		RELATED_CONTENT,
		CONTENT_IDENTIFIER,
		MPE_FEC,
		RESOLUTION_NOTIFICATION,
		MPE_IFEC,
		DISCONTINUITY_INFORMATION,
		SELECTION_INFORMATION,
		CA_MESSAGE_ECM_0,
		CA_MESSAGE_ECM_1,
		CA_MESSAGE_SYSTEM_PRIVATE_1,
		CA_MESSAGE_SYSTEM_PRIVATE_N,
		SCT,
		FCT,
		TCT,
		SPT,
		CMT,
		TBTP,
		PCR_PACKET_PAYLOAD,
		TRANSMISSION_MODE_SUPPORT_PAYLOAD,
		TIM,
		LL_FEC_PARITY_DATA_TABLE
	}
	[CCode (cheader_filename = "gst/mpegts/mpegts.h", cprefix = "GST_MTS_TABLE_ID_SCTE_", has_type_id = false)]
	public enum SectionSCTETableID {
		EAS,
		EBIF,
		RESERVED,
		EISS,
		DII,
		DDB,
		SPLICE
	}
	[CCode (cheader_filename = "gst/mpegts/mpegts.h", cprefix = "GST_MTS_TABLE_ID_", has_type_id = false)]
	public enum SectionTableID {
		PROGRAM_ASSOCIATION,
		CONDITIONAL_ACCESS,
		TS_PROGRAM_MAP,
		TS_DESCRIPTION,
		@14496_SCENE_DESCRIPTION,
		@14496_OBJET_DESCRIPTOR,
		METADATA,
		IPMP_CONTROL_INFORMATION,
		DSM_CC_MULTIPROTO_ENCAPSULATED_DATA,
		DSM_CC_U_N_MESSAGES,
		DSM_CC_DOWNLOAD_DATA_MESSAGES,
		DSM_CC_STREAM_DESCRIPTORS,
		DSM_CC_PRIVATE_DATA,
		DSM_CC_ADDRESSABLE_SECTIONS,
		UNSET
	}
	[CCode (cheader_filename = "gst/mpegts/mpegts.h", cprefix = "GST_MPEGTS_SECTION_", has_type_id = false)]
	public enum SectionType {
		UNKNOWN,
		PAT,
		PMT,
		CAT,
		TSDT,
		EIT,
		NIT,
		BAT,
		SDT,
		TDT,
		TOT,
		ATSC_TVCT,
		ATSC_CVCT,
		ATSC_MGT,
		ATSC_ETT,
		ATSC_EIT,
		ATSC_STT
	}
	[CCode (cheader_filename = "gst/mpegts/mpegts.h", cprefix = "GST_MPEGTS_STREAM_TYPE_", has_type_id = false)]
	public enum StreamType {
		RESERVED_00,
		VIDEO_MPEG1,
		VIDEO_MPEG2,
		AUDIO_MPEG1,
		AUDIO_MPEG2,
		PRIVATE_SECTIONS,
		PRIVATE_PES_PACKETS,
		MHEG,
		DSM_CC,
		H_222_1,
		DSMCC_A,
		DSMCC_B,
		DSMCC_C,
		DSMCC_D,
		AUXILIARY,
		AUDIO_AAC_ADTS,
		VIDEO_MPEG4,
		AUDIO_AAC_LATM,
		SL_FLEXMUX_PES_PACKETS,
		SL_FLEXMUX_SECTIONS,
		SYNCHRONIZED_DOWNLOAD,
		METADATA_PES_PACKETS,
		METADATA_SECTIONS,
		METADATA_DATA_CAROUSEL,
		METADATA_OBJECT_CAROUSEL,
		METADATA_SYNCHRONIZED_DOWNLOAD,
		MPEG2_IPMP,
		VIDEO_H264,
		AUDIO_AAC_CLEAN,
		MPEG4_TIMED_TEXT,
		VIDEO_RVC,
		VIDEO_H264_SVC_SUB_BITSTREAM,
		VIDEO_H264_MVC_SUB_BITSTREAM,
		VIDEO_JP2K,
		VIDEO_MPEG2_STEREO_ADDITIONAL_VIEW,
		VIDEO_H264_STEREO_ADDITIONAL_VIEW,
		VIDEO_HEVC,
		IPMP_STREAM
	}
	[CCode (cheader_filename = "gst/mpegts/mpegts.h", cprefix = "GST_MPEGTS_GUARD_INTERVAL_", has_type_id = false)]
	public enum TerrestrialGuardInterval {
		@1_32,
		@1_16,
		@1_8,
		@1_4,
		AUTO,
		@1_128,
		@19_128,
		@19_256,
		PN420,
		PN595,
		PN945
	}
	[CCode (cheader_filename = "gst/mpegts/mpegts.h", cprefix = "GST_MPEGTS_", has_type_id = false)]
	public enum TerrestrialHierarchy {
		[CCode (cname = "GST_MPEGTS_HIERARCHY_NONE")]
		NONE,
		[CCode (cname = "GST_MPEGTS_HIERARCHY_1")]
		@1,
		[CCode (cname = "GST_MPEGTS_HIERARCHY_2")]
		@2,
		[CCode (cname = "GST_MPEGTS_HIERARCHY_4")]
		@4,
		[CCode (cname = "GST_MPEGTS_HIERARCHY_AUTO")]
		AUTO
	}
	[CCode (cheader_filename = "gst/mpegts/mpegts.h", cprefix = "GST_MPEGTS_TRANSMISSION_MODE_", has_type_id = false)]
	public enum TerrestrialTransmissionMode {
		@2K,
		@8K,
		AUTO,
		@4K,
		@1K,
		@16K,
		@32K,
		C1,
		C3780
	}
	[CCode (cheader_filename = "gst/mpegts/mpegts.h", has_target = false)]
	public delegate bool PacketizeFunc (GstMpegts.Section section);
	[CCode (cheader_filename = "gst/mpegts/mpegts.h")]
	public static void dvb_component_descriptor_free (GstMpegts.ComponentDescriptor source);
	[CCode (cheader_filename = "gst/mpegts/mpegts.h", cname = "gst_event_parse_mpegts_section")]
	public static GstMpegts.Section event_parse_mpegts_section (Gst.Event event);
	[CCode (cheader_filename = "gst/mpegts/mpegts.h")]
	public static unowned GstMpegts.Descriptor find_descriptor (GLib.GenericArray<GstMpegts.Descriptor> descriptors, uint8 tag);
	[CCode (cheader_filename = "gst/mpegts/mpegts.h")]
	public static void initialize ();
	[CCode (cheader_filename = "gst/mpegts/mpegts.h", cname = "gst_message_new_mpegts_section")]
	public static Gst.Message message_new_mpegts_section (Gst.Object parent, GstMpegts.Section section);
	[CCode (cheader_filename = "gst/mpegts/mpegts.h", cname = "gst_message_parse_mpegts_section")]
	public static GstMpegts.Section message_parse_mpegts_section (Gst.Message message);
	[CCode (cheader_filename = "gst/mpegts/mpegts.h")]
	public static GLib.GenericArray<GstMpegts.Descriptor> parse_descriptors (uint8 buffer, size_t buf_len);
	[CCode (cheader_filename = "gst/mpegts/mpegts.h")]
	public static GLib.GenericArray<GstMpegts.PatProgram> pat_new ();
}
