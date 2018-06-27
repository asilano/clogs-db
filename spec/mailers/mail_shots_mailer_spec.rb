require "spec_helper"

describe MailShotsMailer do
  describe "mail_shot" do

    it "renders the headers" do
      mail = MailShotsMailer.mail_shot(subject: 'Test subject',
                                       to: 'to@example.org',
                                       body: 'This is my body',
                                       reply_to_addr: 'from@example.org',
                                       attaches: [])
      expect(mail.subject).to eq('Test subject')
      expect(mail.to).to eq(['to@example.org'])
      expect(mail.from).to eq(['clogs@example.com'])
    end

    it "renders the body" do
      mail = MailShotsMailer.mail_shot(subject: 'Test subject',
                                       to: 'to@example.org',
                                       body: 'This is my body',
                                       reply_to_addr: 'from@example.org',
                                       attaches: [])
      expect(mail.body.encoded).to match('This is my body')
      expect(mail.body.encoded).to match("RMID: #{Base64.encode64('from@example.org').chomp}")
    end

    it 'handles attachments' do
      mail = MailShotsMailer.mail_shot(subject: 'Test subject',
                                       to: 'to@example.org',
                                       body: 'This is my body',
                                       reply_to_addr: 'from@example.org',
                                       attaches: [MailShot::Attachment.new('file.txt',
                                                                           'A text file',
                                                                           'text/plain'),
                                                  MailShot::Attachment.new('image.png',
                                                                           'pretend-this-is-an-image',
                                                                           'image/png')
                                                 ])
      expect(mail.attachments.size).to eq 2
      attachment = mail.attachments[0]
      expect(attachment.content_type).to start_with('text/plain')
      expect(attachment.filename).to eq 'file.txt'
      attachment = mail.attachments[1]
      expect(attachment.content_type).to start_with('image/png')
      expect(attachment.filename).to eq 'image.png'
    end
  end

end
