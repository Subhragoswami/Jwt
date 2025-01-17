@Service
@RequiredArgsConstructor
public class NotificationListener {

    private final Logger log = LoggerFactory.getLogger(NotificationListener.class);
    private final NotificationDao notificationDao;

    @KafkaListener(topics = "${kafka.topics.email}")
    public void consumeEmailTopic(@Payload MerchantEmailDto emailDto, 
                                  @Header(KafkaHeaders.RECEIVED_TOPIC) String topic) {
        log.info("Consumed email notification from topic [{}]: {}", topic, emailDto);
        NotificationManagement notification = new NotificationManagement();
        notification.setNotificationType(NotificationType.EMAIL);
        notificationDao.sendEmailNotification(emailDto, notification);
    }

    @KafkaListener(topics = "${kafka.topics.sms}")
    public void consumeSmsTopic(@Payload SmsRequest smsRequest, 
                                @Header(KafkaHeaders.RECEIVED_TOPIC) String topic) {
        log.info("Consumed SMS notification from topic [{}]: {}", topic, smsRequest);
        NotificationManagement notification = new NotificationManagement();
        notification.setNotificationType(NotificationType.SMS);
        notificationDao.sendSmsNotification(smsRequest, notification);
    }
}




@Component
@RequiredArgsConstructor
public class NotificationKafkaProducer {

    private final Logger log = LoggerFactory.getLogger(NotificationKafkaProducer.class);
    private final KafkaTemplate<String, Object> kafkaTemplate;
    private final KafkaProducerConfig producerConfig;

    public void publishEmail(MerchantEmailDto emailDto) {
        log.info("Publishing email notification: {}", emailDto);
        kafkaTemplate.send(producerConfig.getTopicEmail(), emailDto);
    }

    public void publishSms(SmsRequest smsRequest) {
        log.info("Publishing SMS notification: {}", smsRequest);
        kafkaTemplate.send(producerConfig.getTopicSMS(), smsRequest);
    }
}


@Component
@RequiredArgsConstructor
public class NotificationDao {

    private final Logger log = LoggerFactory.getLogger(NotificationDao.class);
    private final NotificationKafkaProducer kafkaProducer;

    public void sendEmailNotification(MerchantEmailDto emailDto, NotificationManagement notification) {
        log.info("Sending email notification via Kafka: {}", emailDto);
        kafkaProducer.publishEmail(emailDto);
        notification.setNotificationType(NotificationType.EMAIL);
        notification.setContent(emailDto.getContent().toString());
    }

    public void sendSmsNotification(SmsRequest smsRequest, NotificationManagement notification) {
        log.info("Sending SMS notification via Kafka: {}", smsRequest);
        kafkaProducer.publishSms(smsRequest);
        notification.setNotificationType(NotificationType.SMS);
        notification.setContent(smsRequest.getMessage());
    }
}




@Configuration
@Getter
public class KafkaProducerConfig {

    @Value("${spring.kafka.bootstrap-servers}")
    private String bootstrapServers;

    @Value("${kafka.topics.email}")
    private String topicEmail;

    @Value("${kafka.topics.sms}")
    private String topicSMS;

    @Bean
    public ProducerFactory<String, Object> producerFactory() {
        Map<String, Object> configProps = new HashMap<>();
        configProps.put(ProducerConfig.BOOTSTRAP_SERVERS_CONFIG, bootstrapServers);
        configProps.put(ProducerConfig.KEY_SERIALIZER_CLASS_CONFIG, StringSerializer.class);
        configProps.put(ProducerConfig.VALUE_SERIALIZER_CLASS_CONFIG, JsonSerializer.class);
        return new DefaultKafkaProducerFactory<>(configProps);
    }

    @Bean
    public KafkaTemplate<String, Object> kafkaTemplate() {
        return new KafkaTemplate<>(producerFactory());
    }
}




