#setwd("D:/Documents/DEV/fdiwg/fdi-terms")

#read list of fdi measurement
measurements = readr::read_csv("https://raw.githubusercontent.com/fdiwg/fdi-codelists/main/global/fdi/cl_measurement.csv")

#auto-generate simplified measurement terms
all_measurement_terms = do.call("rbind", lapply(measurements$code, function(code){
	measurement = measurements[measurements$code == code,]
	measurement_types = readr::read_csv(sprintf("https://raw.githubusercontent.com/fdiwg/fdi-codelists/main/global/fdi/cl_measurement_types_%s.csv", code))
	measurement_terms = do.call("rbind", lapply(measurement_types$code, function(measurement_type_code){
		measurement_type = measurement_types[measurement_types$code == measurement_type_code,]
		term = paste0(code, "_", measurement_type_code, c("", "_unit", "_status"))
		term_df = data.frame(
			urn = paste0("urn:fdi:term:", term),
			term = term,
			replaced_by = NA,
			status_fdi = "pending",
			domain = "fisheries",
			subdomain = NA,
			model = "simplified",
			type = c("variable", rep("attribute", 2)),
			code = term,
			uri = NA,
			label = c(measurement_type$label, paste(measurement_type$label, "unit"), paste(measurement_type$label, "status")),
			definition = measurement_type$definition,
			preferred_classification_system = NA,
			alternate_classification_system = NA,
			cwp_endorsement = NA,
			stringsAsFactors = FALSE
		)
		return(term_df)
	}))
	return(measurement_terms)
}))

readr::write_csv(all_measurement_terms, "fdi_simplified_measurement_terms.csv")

#merge fditerms
fditerms = do.call("rbind", lapply(list.files(pattern = "fdi_"), readr::read_csv))
readr::write_csv(fditerms, "fditerms.csv")